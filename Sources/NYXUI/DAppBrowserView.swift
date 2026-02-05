import SwiftUI

#if os(iOS)
struct DAppBrowserView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("DApp Browser")
                .font(.largeTitle.bold())
            Text("WalletConnect and embedded browser will be available here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Coming soon")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("DApp")
    }
}
#endif
