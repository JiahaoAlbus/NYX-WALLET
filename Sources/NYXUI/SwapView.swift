import SwiftUI

#if os(iOS)
struct SwapView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Swap")
                .font(.largeTitle.bold())
            Text("Swap aggregation is wired to 0x (EVM) and Jupiter (Solana).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Coming soon")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("Swap")
    }
}
#endif
