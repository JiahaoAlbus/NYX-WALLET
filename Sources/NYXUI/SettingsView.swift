import SwiftUI
import NYXCore

#if os(iOS)
struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @State private var environment: AppEnvironment = .mainnet
    @State private var language: AppLanguage = .system

    var body: some View {
        Form {
            Section(state.localizer.text("settings.environment")) {
                Picker(state.localizer.text("settings.environment"), selection: $environment) {
                    Text(state.localizer.text("settings.mainnet")).tag(AppEnvironment.mainnet)
                    Text(state.localizer.text("settings.testnet")).tag(AppEnvironment.testnet)
                }
                .pickerStyle(.segmented)
                Text("Restart app to apply network changes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(state.localizer.text("settings.language")) {
                Picker(state.localizer.text("settings.language"), selection: $language) {
                    Text(state.localizer.text("settings.system")).tag(AppLanguage.system)
                    Text(state.localizer.text("settings.english")).tag(AppLanguage.english)
                    Text(state.localizer.text("settings.chinese")).tag(AppLanguage.chinese)
                }
            }
        }
        .navigationTitle(state.localizer.text("nav.settings"))
        .onAppear {
            environment = state.settingsStore.loadEnvironment()
            language = state.settingsStore.loadLanguage()
        }
        .onChange(of: environment) { newValue in
            state.updateEnvironment(newValue)
        }
        .onChange(of: language) { newValue in
            state.updateLanguage(newValue)
        }
    }
}
#endif
