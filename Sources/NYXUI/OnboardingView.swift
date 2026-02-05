import SwiftUI

#if os(iOS)
struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var errorMessage: String?
    @State private var showBackup: Bool = false
    @State private var mnemonicPhrase: String = ""
    @State private var showImport: Bool = false
    @State private var importPhrase: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(state.localizer.text("onboarding.title"))
                .font(.largeTitle.bold())

            Text(state.localizer.text("onboarding.subtitle"))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(state.localizer.text("button.create")) {
                Task {
                    await createWallet()
                }
            }
            .buttonStyle(.borderedProminent)

            Button(state.localizer.text("button.import")) {
                showImport = true
            }
            .buttonStyle(.bordered)

            Button(state.localizer.text("button.unlock")) {
                Task {
                    await state.unlockWallet()
                }
            }
            .buttonStyle(.bordered)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .padding(24)
        .sheet(isPresented: $showBackup) {
            BackupView(mnemonic: mnemonicPhrase)
        }
        .sheet(isPresented: $showImport) {
            VStack(spacing: 16) {
                Text("Import Wallet")
                    .font(.headline)
                TextEditor(text: $importPhrase)
                    .frame(height: 120)
                    .border(Color.secondary)
                Button("Import") {
                    Task { await importWallet() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }

    private func createWallet() async {
        do {
            let mnemonic = try state.keyManager.generateMnemonic()
            try state.vault.storeMnemonic(mnemonic)
            mnemonicPhrase = mnemonic
            let addresses = try state.keyManager.deriveAddresses(mnemonic: mnemonic, environment: state.settingsStore.loadEnvironment())
            state.addresses = addresses
            showBackup = true
            state.isInitialized = true
        } catch {
            errorMessage = "Failed to create wallet: \(error.localizedDescription)"
        }
    }

    private func importWallet() async {
        do {
            let phrase = importPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
            try state.vault.storeMnemonic(phrase)
            let addresses = try state.keyManager.deriveAddresses(mnemonic: phrase, environment: state.settingsStore.loadEnvironment())
            state.addresses = addresses
            state.isInitialized = true
            showImport = false
        } catch {
            errorMessage = "Failed to import wallet: \\(error.localizedDescription)"
        }
    }
}
#else
struct OnboardingView {
}
#endif
