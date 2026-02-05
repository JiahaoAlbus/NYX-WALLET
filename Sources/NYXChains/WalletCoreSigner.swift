import Foundation

#if os(iOS)
import WalletCore
import SwiftProtobuf
import BigInt

public enum SigningError: Error {
    case missingPrivateKey
    case invalidInput
}

public final class WalletCoreSigner {
    public init() {}

    public func signEvmTransfer(
        privateKey: Data,
        toAddress: String,
        amount: BigUInt,
        nonce: BigUInt,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        chainId: BigUInt,
        coin: CoinType
    ) -> Data {
        let input = EthereumSigningInput.with {
            $0.chainID = chainId.data
            $0.nonce = nonce.data
            $0.gasPrice = gasPrice.data
            $0.gasLimit = gasLimit.data
            $0.toAddress = toAddress
            $0.privateKey = privateKey
            $0.transaction = EthereumTransaction.with {
                $0.transfer = EthereumTransaction.Transfer.with {
                    $0.amount = amount.data
                }
            }
        }
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coin)
        return output.encoded
    }

    public func signSolanaTransfer(
        privateKey: Data,
        toAddress: String,
        amount: UInt64,
        recentBlockhash: String
    ) -> String {
        let transfer = SolanaTransfer.with {
            $0.recipient = toAddress
            $0.value = amount
        }
        let input = SolanaSigningInput.with {
            $0.transferTransaction = transfer
            $0.recentBlockhash = recentBlockhash
            $0.privateKey = privateKey
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: .solana)
        return output.encoded
    }

    public func signTronTransfer(
        privateKey: Data,
        ownerAddress: String,
        toAddress: String,
        amount: Int64,
        blockHeader: TronBlockHeader,
        timestamp: Int64,
        expiration: Int64
    ) -> TronSigningOutput {
        let contract = TronTransferContract.with {
            $0.ownerAddress = ownerAddress
            $0.toAddress = toAddress
            $0.amount = amount
        }
        let input = TronSigningInput.with {
            $0.transaction = TronTransaction.with {
                $0.contractOneof = .transfer(contract)
                $0.timestamp = timestamp
                $0.blockHeader = blockHeader
                $0.expiration = expiration
            }
            $0.privateKey = privateKey
        }
        return AnySigner.sign(input: input, coin: .tron)
    }

    public func signBitcoinP2WPKH(
        input: BitcoinSigningInput
    ) -> BitcoinSigningOutput {
        return AnySigner.sign(input: input, coin: .bitcoin)
    }
}
#else
public enum SigningError: Error {
    case missingPrivateKey
    case invalidInput
}

public final class WalletCoreSigner {
    public init() {}
}
#endif
