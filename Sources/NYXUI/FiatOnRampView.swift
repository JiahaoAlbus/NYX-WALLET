import SwiftUI

#if os(iOS)
struct FiatOnRampView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Buy Crypto")
                .font(.largeTitle.bold())
            Text("MoonPay integration will be enabled after KYB.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Coming soon")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("Buy Crypto")
    }
}
#endif
