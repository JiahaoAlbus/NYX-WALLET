import SwiftUI

#if os(iOS)
struct BackupView: View {
    let mnemonic: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Backup")
                .font(.largeTitle.bold())

            Text("Write down this recovery phrase and store it offline. Anyone with it can access your wallet.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text(mnemonic)
                .font(.system(.footnote, design: .monospaced))
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Text("Loss of this phrase means permanent loss of access.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}
#endif
