import SwiftUI
import NYXCore

#if os(iOS)
struct NodeSettingsView: View {
    @EnvironmentObject var state: AppState
    @State private var environment: AppEnvironment = .mainnet
    @State private var customURL: String = ""
    @State private var selectedChain: ChainSelection = .ethereum

    private enum ChainSelection: String, CaseIterable, Identifiable {
        case ethereum
        case bnb
        case bitcoin
        case solana
        case tron

        var id: String { rawValue }

        func chainId(environment: AppEnvironment) -> String {
            switch (self, environment) {
            case (.ethereum, .mainnet): return "evm:1"
            case (.ethereum, .testnet): return "evm:11155111"
            case (.bnb, .mainnet): return "evm:56"
            case (.bnb, .testnet): return "evm:97"
            case (.bitcoin, .mainnet): return "btc:mainnet"
            case (.bitcoin, .testnet): return "btc:testnet"
            case (.solana, .mainnet): return "sol:mainnet"
            case (.solana, .testnet): return "sol:devnet"
            case (.tron, .mainnet): return "tron:mainnet"
            case (.tron, .testnet): return "tron:shasta"
            }
        }

        var displayName: String {
            switch self {
            case .ethereum: return "Ethereum"
            case .bnb: return "BNB Chain"
            case .bitcoin: return "Bitcoin"
            case .solana: return "Solana"
            case .tron: return "TRON"
            }
        }
    }

    var body: some View {
        Form {
            Section(state.localizer.text("settings.environment")) {
                Picker(state.localizer.text("settings.environment"), selection: $environment) {
                    Text(state.localizer.text("settings.mainnet")).tag(AppEnvironment.mainnet)
                    Text(state.localizer.text("settings.testnet")).tag(AppEnvironment.testnet)
                }
                .pickerStyle(.segmented)
            }

            Section("Chain") {
                Picker("Chain", selection: $selectedChain) {
                    ForEach(ChainSelection.allCases) { chain in
                        Text(chain.displayName).tag(chain)
                    }
                }
            }

            Section("Custom RPC") {
                TextField("https://...", text: $customURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                Button("Apply Custom URL") {
                    saveCustom()
                }
                Button("Clear Custom URL") {
                    clearCustom()
                }
            }

            Section("Notes") {
                Text("Public RPCs are rate-limited. For production, replace with paid endpoints.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(state.localizer.text("nav.nodes"))
        .onAppear {
            environment = state.settingsStore.loadEnvironment()
            customURL = ""
        }
    }

    private func saveCustom() {
        guard let url = URL(string: customURL) else { return }
        let store = DefaultNodeStore()
        store.saveCustomURL(url, for: selectedChain.chainId(environment: environment))
    }

    private func clearCustom() {
        let store = DefaultNodeStore()
        store.saveCustomURL(nil, for: selectedChain.chainId(environment: environment))
        customURL = ""
    }
}
#endif
