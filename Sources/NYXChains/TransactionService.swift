#if os(iOS)
import Foundation
import BigInt
import WalletCore
import SwiftProtobuf
import NYXCore
import NYXSecurity

public final class TransactionService {
    private let rpcClient: RPCClient
    private let signer: WalletCoreSigner
    private let appConfig: AppConfig
    private let vault: SecureVault
    private let feePolicy: FeePolicy

    public init(rpcClient: RPCClient, signer: WalletCoreSigner, appConfig: AppConfig, vault: SecureVault, feePolicy: FeePolicy) {
        self.rpcClient = rpcClient
        self.signer = signer
        self.appConfig = appConfig
        self.vault = vault
        self.feePolicy = feePolicy
    }

    public func send(draft: TransactionDraft) async throws -> [String] {
        let feeAmount = (draft.amount * feePolicy.serviceFeeRate).rounded(scale: 8)
        switch draft.chainId {
        case "evm:1", "evm:56":
            return try await sendEvm(draft: draft, feeAmount: feeAmount)
        case "btc:mainnet", "btc:testnet":
            return try await sendBitcoin(draft: draft, feeAmount: feeAmount)
        case "sol:mainnet", "sol:devnet":
            return try await sendSolana(draft: draft, feeAmount: feeAmount)
        case "tron:mainnet", "tron:shasta":
            return try await sendTron(draft: draft, feeAmount: feeAmount)
        default:
            return []
        }
    }

    private func sendEvm(draft: TransactionDraft, feeAmount: Decimal) async throws -> [String] {
        guard let rpc = appConfig.rpcConfigs.first(where: { $0.chainId == draft.chainId }) else { return [] }
        let mnemonic = try vault.loadMnemonic(prompt: "Unlock NYX WALLIET")
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else { throw SigningError.invalidInput }
        let coin: CoinType = draft.chainId == "evm:56" ? .smartChain : .ethereum
        let key = wallet.getKeyForCoin(coin: coin)
        let from = wallet.getAddressForCoin(coin: coin)

        let serviceRecipient = FeeRecipientRegistry.defaultConfig().first(where: { $0.chainId == draft.chainId })?.address ?? ""
        let evm = EVMService(client: rpcClient, url: rpc.rpcURL)
        let nonce = try await evm.nonce(address: from)
        let gasPrice = try await evm.gasPrice()
        let chainId = BigUInt(draft.chainId == "evm:56" ? 56 : 1)

        var txids: [String] = []

        if let contract = draft.asset.contractAddress {
            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let dataTx = EthereumTransaction.with {
                $0.erc20Transfer = EthereumTransaction.ERC20Transfer.with {
                    $0.to = draft.to.value
                    $0.amount = amount.data
                }
            }
            let input = EthereumSigningInput.with {
                $0.chainID = chainId.data
                $0.nonce = nonce.data
                $0.gasPrice = gasPrice.data
                $0.gasLimit = BigUInt(80000).data
                $0.toAddress = contract
                $0.privateKey = key.data
                $0.transaction = dataTx
            }
            let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coin)
            let txid = try await evm.sendRawTransaction(output.encoded)
            txids.append(txid)

            let feeAmountBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let feeTx = EthereumTransaction.with {
                $0.erc20Transfer = EthereumTransaction.ERC20Transfer.with {
                    $0.to = serviceRecipient
                    $0.amount = feeAmountBig.data
                }
            }
            let inputFee = EthereumSigningInput.with {
                $0.chainID = chainId.data
                $0.nonce = (nonce + 1).data
                $0.gasPrice = gasPrice.data
                $0.gasLimit = BigUInt(80000).data
                $0.toAddress = contract
                $0.privateKey = key.data
                $0.transaction = feeTx
            }
            let outputFee: EthereumSigningOutput = AnySigner.sign(input: inputFee, coin: coin)
            let feeTxid = try await evm.sendRawTransaction(outputFee.encoded)
            txids.append(feeTxid)
        } else {
            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let signed = signer.signEvmTransfer(privateKey: key.data, toAddress: draft.to.value, amount: amount, nonce: nonce, gasPrice: gasPrice, gasLimit: BigUInt(21000), chainId: chainId, coin: coin)
            let txid = try await evm.sendRawTransaction(signed)
            txids.append(txid)

            let feeBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let signedFee = signer.signEvmTransfer(privateKey: key.data, toAddress: serviceRecipient, amount: feeBig, nonce: nonce + 1, gasPrice: gasPrice, gasLimit: BigUInt(21000), chainId: chainId, coin: coin)
            let feeTxid = try await evm.sendRawTransaction(signedFee)
            txids.append(feeTxid)
        }

        return txids
    }

    private func sendSolana(draft: TransactionDraft, feeAmount: Decimal) async throws -> [String] {
        guard let rpc = appConfig.rpcConfigs.first(where: { $0.chainId == draft.chainId }) else { return [] }
        let mnemonic = try vault.loadMnemonic(prompt: "Unlock NYX WALLIET")
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else { throw SigningError.invalidInput }
        let key = wallet.getKeyForCoin(coin: .solana)
        let from = wallet.getAddressForCoin(coin: .solana)
        let sol = SolanaService(client: rpcClient, url: rpc.rpcURL)
        let blockhash = try await sol.latestBlockhash()
        let serviceRecipient = FeeRecipientRegistry.defaultConfig().first(where: { $0.chainId == draft.chainId })?.address ?? ""

        var txids: [String] = []

        if let contract = draft.asset.contractAddress {
            let senderToken = try await sol.tokenAccount(owner: from, mint: contract)
            let recipientToken = try await sol.tokenAccount(owner: draft.to.value, mint: contract)
            guard let senderToken, let recipientToken else { return [] }

            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let transfer = SolanaTokenTransfer.with {
                $0.tokenMintAddress = contract
                $0.senderTokenAddress = senderToken
                $0.recipientTokenAddress = recipientToken
                $0.amount = UInt64(amount)
                $0.decimals = UInt32(draft.asset.decimals)
            }
            let input = SolanaSigningInput.with {
                $0.tokenTransferTransaction = transfer
                $0.recentBlockhash = blockhash
                $0.privateKey = key.data
            }
            let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: .solana)
            let txid = try await sol.sendTransaction(base64: output.encoded)
            txids.append(txid)

            let feeBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let serviceToken = try await sol.tokenAccount(owner: serviceRecipient, mint: contract) ?? recipientToken
            let feeTransfer = SolanaTokenTransfer.with {
                $0.tokenMintAddress = contract
                $0.senderTokenAddress = senderToken
                $0.recipientTokenAddress = serviceToken
                $0.amount = UInt64(feeBig)
                $0.decimals = UInt32(draft.asset.decimals)
            }
            let inputFee = SolanaSigningInput.with {
                $0.tokenTransferTransaction = feeTransfer
                $0.recentBlockhash = blockhash
                $0.privateKey = key.data
            }
            let outputFee: SolanaSigningOutput = AnySigner.sign(input: inputFee, coin: .solana)
            let feeTxid = try await sol.sendTransaction(base64: outputFee.encoded)
            txids.append(feeTxid)
        } else {
            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let signed = signer.signSolanaTransfer(privateKey: key.data, toAddress: draft.to.value, amount: UInt64(amount), recentBlockhash: blockhash)
            let txid = try await sol.sendTransaction(base64: signed)
            txids.append(txid)

            let feeBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let signedFee = signer.signSolanaTransfer(privateKey: key.data, toAddress: serviceRecipient, amount: UInt64(feeBig), recentBlockhash: blockhash)
            let feeTxid = try await sol.sendTransaction(base64: signedFee)
            txids.append(feeTxid)
        }
        return txids
    }

    private func sendTron(draft: TransactionDraft, feeAmount: Decimal) async throws -> [String] {
        guard let rpc = appConfig.rpcConfigs.first(where: { $0.chainId == draft.chainId }) else { return [] }
        let mnemonic = try vault.loadMnemonic(prompt: "Unlock NYX WALLIET")
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else { throw SigningError.invalidInput }
        let key = wallet.getKeyForCoin(coin: .tron)
        let from = wallet.getAddressForCoin(coin: .tron)
        let serviceRecipient = FeeRecipientRegistry.defaultConfig().first(where: { $0.chainId == draft.chainId })?.address ?? ""
        let tron = TronService(client: rpcClient, url: rpc.rpcURL, headers: rpc.headers)
        let block = try await tron.getNowBlock()

        let header = TronBlockHeader.with {
            $0.number = block.blockHeader.rawData.number
            $0.timestamp = block.blockHeader.rawData.timestamp
            $0.version = Int32(block.blockHeader.rawData.version)
            $0.txTrieRoot = Data(hexString: block.blockHeader.rawData.txTrieRoot) ?? Data()
            $0.parentHash = Data(hexString: block.blockHeader.rawData.parentHash) ?? Data()
            $0.witnessAddress = Data(hexString: block.blockHeader.rawData.witnessAddress) ?? Data()
        }
        let timestamp = block.blockHeader.rawData.timestamp
        let expiration = timestamp + 10 * 60 * 1000

        var txids: [String] = []

        if let contract = draft.asset.contractAddress {
            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let contractMsg = TronTransferTRC20Contract.with {
                $0.contractAddress = contract
                $0.ownerAddress = from
                $0.toAddress = draft.to.value
                $0.amount = amount.data
            }
            let input = TronSigningInput.with {
                $0.transaction = TronTransaction.with {
                    $0.contractOneof = .transferTrc20Contract(contractMsg)
                    $0.timestamp = timestamp
                    $0.blockHeader = header
                    $0.expiration = expiration
                }
                $0.privateKey = key.data
            }
            let output: TronSigningOutput = AnySigner.sign(input: input, coin: .tron)
            let res = try await tron.broadcast(json: output.json)
            txids.append(res.txid ?? "")

            let feeBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let feeContract = TronTransferTRC20Contract.with {
                $0.contractAddress = contract
                $0.ownerAddress = from
                $0.toAddress = serviceRecipient
                $0.amount = feeBig.data
            }
            let inputFee = TronSigningInput.with {
                $0.transaction = TronTransaction.with {
                    $0.contractOneof = .transferTrc20Contract(feeContract)
                    $0.timestamp = timestamp
                    $0.blockHeader = header
                    $0.expiration = expiration
                }
                $0.privateKey = key.data
            }
            let outputFee: TronSigningOutput = AnySigner.sign(input: inputFee, coin: .tron)
            let resFee = try await tron.broadcast(json: outputFee.json)
            txids.append(resFee.txid ?? "")
        } else {
            let amount = try decimalToBigUInt(draft.amount, decimals: draft.asset.decimals)
            let output = signer.signTronTransfer(privateKey: key.data, ownerAddress: from, toAddress: draft.to.value, amount: Int64(amount), blockHeader: header, timestamp: timestamp, expiration: expiration)
            let res = try await tron.broadcast(json: output.json)
            txids.append(res.txid ?? "")

            let feeBig = try decimalToBigUInt(feeAmount, decimals: draft.asset.decimals)
            let feeOutput = signer.signTronTransfer(privateKey: key.data, ownerAddress: from, toAddress: serviceRecipient, amount: Int64(feeBig), blockHeader: header, timestamp: timestamp, expiration: expiration)
            let resFee = try await tron.broadcast(json: feeOutput.json)
            txids.append(resFee.txid ?? "")
        }
        return txids
    }

    private func sendBitcoin(draft: TransactionDraft, feeAmount: Decimal) async throws -> [String] {
        guard let rpc = appConfig.rpcConfigs.first(where: { $0.chainId == draft.chainId }) else { return [] }
        let mnemonic = try vault.loadMnemonic(prompt: "Unlock NYX WALLIET")
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else { throw SigningError.invalidInput }
        let from = wallet.getAddressDerivation(coin: .bitcoin, derivation: draft.chainId == "btc:testnet" ? .bitcoinTestnet : .bitcoinSegwit)
        let serviceRecipient = FeeRecipientRegistry.defaultConfig().first(where: { $0.chainId == draft.chainId })?.address ?? ""
        let btc = BitcoinService(client: rpcClient, baseURL: rpc.rpcURL)

        let utxos = try await btc.utxos(address: from)
        let feeRate = try await btc.feeRate()

        let amount = try decimalToBigUInt(draft.amount, decimals: 8)
        let feeBig = try decimalToBigUInt(feeAmount, decimals: 8)
        let total = amount + feeBig

        var input = BitcoinSigningInput.with {
            $0.amount = Int64(amount)
            $0.byteFee = feeRate
            $0.toAddress = draft.to.value
            $0.changeAddress = from
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: .bitcoin)
        }
        let extra = BitcoinOutputAddress.with {
            $0.toAddress = serviceRecipient
            $0.amount = Int64(feeBig)
        }
        input.extraOutputs.append(extra)

        var accumulated: Int64 = 0
        for utxo in utxos {
            let tx = try await btc.tx(txid: utxo.txid)
            let vout = tx.vout[utxo.vout]
            guard let scriptData = Data(hexString: vout.scriptpubkey) else { continue }
            let unspent = BitcoinUnspentTransaction.with {
                $0.outPoint.hash = Data.reverse(hexString: utxo.txid)
                $0.outPoint.index = UInt32(utxo.vout)
                $0.outPoint.sequence = UInt32.max
                $0.amount = utxo.value
                $0.script = scriptData
            }
            input.utxo.append(unspent)
            accumulated += utxo.value
            if accumulated >= Int64(total) {
                break
            }
        }

        input.privateKey.append(wallet.getKeyForCoin(coin: .bitcoin).data)

        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: .bitcoin)
        if plan.amount == 0 {
            return []
        }

        let output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: .bitcoin)
        let txHex = output.encoded.hexString
        let txid = try await btc.broadcast(txHex: txHex)
        return [txid]
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .bankers)
        return result
    }
}

private extension Data {
    func toHexString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
#else
import Foundation
import NYXCore
import NYXSecurity

public final class TransactionService {
    public init(rpcClient: RPCClient, signer: WalletCoreSigner, appConfig: AppConfig, vault: SecureVault, feePolicy: FeePolicy) {}

    public func send(draft: TransactionDraft) async throws -> [String] {
        return []
    }
}
#endif
