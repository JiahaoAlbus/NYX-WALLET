import SwiftUI
import NYXCore
import NYXChains

#if os(iOS)
struct SendView: View {
    @EnvironmentObject var state: AppState
    @State private var toAddress: String = ""
    @State private var amount: String = ""
    @State private var memo: String = ""
    @State private var chain: String = "evm:1"
    @State private var asset: String = "native"
    @State private var fee: FeeBreakdown?
    @State private var risk: RiskResult?
    @State private var errorMessage: String?
    @State private var txids: [String] = []

    private let chainOptions: [(String, String)] = [
        ("evm:1", "Ethereum"),
        ("evm:56", "BNB"),
        ("btc:mainnet", "Bitcoin"),
        ("sol:mainnet", "Solana"),
        ("tron:mainnet", "TRON")
    ]

    var body: some View {
        Form {
            Section("Chain") {
                Picker("Chain", selection: $chain) {
                    ForEach(chainOptions, id: \.0) { item in
                        Text(item.1).tag(item.0)
                    }
                }
            }

            Section("Asset") {
                Picker("Asset", selection: $asset) {
                    Text("Native").tag("native")
                    Text("USDT").tag("usdt")
                }
                .pickerStyle(.segmented)
            }

            Section("From") {
                Text(fromAddress())
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Section("To") {
                TextField("Recipient address", text: $toAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Amount") {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Section("Memo") {
                TextField("Memo (optional)", text: $memo)
            }

            if let fee {
                Section("Fees") {
                    Text("Network: \(fee.networkFee)")
                    Text("Service (1.5%): \(fee.serviceFee)")
                    Text("Total: \(fee.total)")
                        .font(.headline)
                }
            }

            if let risk {
                Section("Risk") {
                    Text("Level: \(risk.level.rawValue)")
                    ForEach(risk.reasons, id: \.self) { reason in
                        Text(reason)
                    }
                }
            }

            if !txids.isEmpty {
                Section("Transaction IDs") {
                    ForEach(txids, id: \.self) { id in
                        Text(id)
                            .font(.system(.footnote, design: .monospaced))
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button("Estimate") {
                Task { await estimate() }
            }
            .buttonStyle(.bordered)

            Button("Send") {
                Task { await send() }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle(state.localizer.text("nav.send"))
    }

    private func estimate() async {
        do {
            guard let amountDecimal = Decimal(string: amount) else { return }
            let asset = assetForChain(chain, assetSelection: asset)
            let draft = TransactionDraft(
                chainId: chain,
                asset: asset,
                from: Address(fromAddress()),
                to: Address(toAddress),
                amount: amountDecimal,
                memo: memo.isEmpty ? nil : memo
            )
            let plan = try await state.planner.plan(draft: draft)
            fee = plan.simulation.estimatedFee
            risk = plan.risk
        } catch {
            errorMessage = "Failed: \(error.localizedDescription)"
        }
    }

    private func send() async {
        do {
            guard let amountDecimal = Decimal(string: amount) else { return }
            let asset = assetForChain(chain, assetSelection: asset)
            let draft = TransactionDraft(
                chainId: chain,
                asset: asset,
                from: Address(fromAddress()),
                to: Address(toAddress),
                amount: amountDecimal,
                memo: memo.isEmpty ? nil : memo
            )
            txids = try await state.transactionService.send(draft: draft)
        } catch {
            errorMessage = "Send failed: \(error.localizedDescription)"
        }
    }

    private func fromAddress() -> String {
        guard let addresses = state.addresses else { return "" }
        switch chain {
        case "evm:1": return addresses.evm
        case "evm:56": return addresses.bnb
        case "btc:mainnet": return addresses.btc
        case "sol:mainnet": return addresses.sol
        case "tron:mainnet": return addresses.tron
        default: return ""
        }
    }

    private func assetForChain(_ chainId: String, assetSelection: String) -> Asset {
        switch chainId {
        case "evm:1":
            if assetSelection == "usdt" {
                return Asset(chainId: chainId, symbol: "USDT", contractAddress: ChainConstants.usdtEthereum.contract, decimals: ChainConstants.usdtEthereum.decimals)
            }
            return Asset(chainId: chainId, symbol: "ETH", contractAddress: nil, decimals: 18)
        case "evm:56":
            if assetSelection == "usdt" {
                return Asset(chainId: chainId, symbol: "USDT", contractAddress: ChainConstants.usdtBnb.contract, decimals: ChainConstants.usdtBnb.decimals)
            }
            return Asset(chainId: chainId, symbol: "BNB", contractAddress: nil, decimals: 18)
        case "btc:mainnet": return Asset(chainId: chainId, symbol: "BTC", contractAddress: nil, decimals: 8)
        case "sol:mainnet":
            if assetSelection == "usdt" {
                return Asset(chainId: chainId, symbol: "USDT", contractAddress: ChainConstants.usdtSol.contract, decimals: ChainConstants.usdtSol.decimals)
            }
            return Asset(chainId: chainId, symbol: "SOL", contractAddress: nil, decimals: 9)
        case "tron:mainnet":
            if assetSelection == "usdt" {
                return Asset(chainId: chainId, symbol: "USDT", contractAddress: ChainConstants.usdtTron.contract, decimals: ChainConstants.usdtTron.decimals)
            }
            return Asset(chainId: chainId, symbol: "TRX", contractAddress: nil, decimals: 6)
        default: return Asset(chainId: chainId, symbol: "", contractAddress: nil, decimals: 18)
        }
    }
}
#endif
