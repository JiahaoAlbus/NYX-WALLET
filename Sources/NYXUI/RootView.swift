import SwiftUI

#if os(iOS)
public struct RootView: View {
    @StateObject private var state = AppState()

    public init() {}

    public var body: some View {
        NavigationStack {
            if state.isInitialized {
                MainTabView()
                    .environmentObject(state)
            } else {
                OnboardingView()
                    .environmentObject(state)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView {
            WalletHomeView()
                .tabItem { Label(state.localizer.text("nav.wallet"), systemImage: "wallet.pass") }

            SwapView()
                .tabItem { Label(state.localizer.text("nav.swap"), systemImage: "arrow.left.arrow.right") }

            NFTView()
                .tabItem { Label(state.localizer.text("nav.nft"), systemImage: "photo.on.rectangle") }

            DAppBrowserView()
                .tabItem { Label(state.localizer.text("nav.dapp"), systemImage: "globe") }

            FiatOnRampView()
                .tabItem { Label(state.localizer.text("nav.buy"), systemImage: "creditcard") }

            SettingsHomeView()
                .tabItem { Label(state.localizer.text("nav.settings"), systemImage: "gearshape") }
        }
    }
}

struct WalletHomeView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(state.localizer.text("app.title"))
                        .font(.largeTitle.bold())
                    Text(state.localizer.text("wallet.secure"))
                        .foregroundStyle(.secondary)
                }

                Section("Assets") {
                    AssetRow(symbol: "ETH", balance: "0.00")
                    AssetRow(symbol: "BNB", balance: "0.00")
                    AssetRow(symbol: "BTC", balance: "0.00")
                    AssetRow(symbol: "SOL", balance: "0.00")
                    AssetRow(symbol: "TRX", balance: "0.00")
                    AssetRow(symbol: "USDT", balance: "0.00")
                }

                Section("Fees") {
                    Text(state.localizer.text("wallet.service_fee"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Actions") {
                    NavigationLink(state.localizer.text("nav.send")) {
                        SendView()
                            .environmentObject(state)
                    }
                    NavigationLink(state.localizer.text("nav.receive")) {
                        ReceiveView()
                    }
                }
            }
        }
    }
}

struct AssetRow: View {
    let symbol: String
    let balance: String

    var body: some View {
        HStack {
            Text(symbol)
            Spacer()
            Text(balance)
                .foregroundStyle(.secondary)
        }
    }
}

struct SettingsHomeView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(state.localizer.text("nav.nodes")) {
                        NodeSettingsView()
                            .environmentObject(state)
                    }
                    NavigationLink(state.localizer.text("nav.settings")) {
                        SettingsView()
                            .environmentObject(state)
                    }
                    Button(state.localizer.text("button.lock")) {
                        state.isInitialized = false
                    }
                }
            }
        }
    }
}
#else
public struct RootView {
    public init() {}
}
#endif
