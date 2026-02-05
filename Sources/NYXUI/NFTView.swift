import SwiftUI

#if os(iOS)
struct NFTView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("NFT")
                .font(.largeTitle.bold())
            Text("NFT marketplace integration is configured but not yet implemented.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Coming soon")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("NFT")
    }
}
#endif
