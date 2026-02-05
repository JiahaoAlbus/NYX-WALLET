import SwiftUI

#if os(iOS)
struct ReceiveView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text(state.localizer.text("nav.receive"))
                .font(.largeTitle.bold())

            if let addresses = state.addresses {
                VStack(alignment: .leading, spacing: 8) {
                    AddressRow(label: "Ethereum", address: addresses.evm)
                    AddressRow(label: "BNB", address: addresses.bnb)
                    AddressRow(label: "Bitcoin", address: addresses.btc)
                    AddressRow(label: "Solana", address: addresses.sol)
                    AddressRow(label: "TRON", address: addresses.tron)
                }
            } else {
                Text("No address loaded.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .navigationTitle(state.localizer.text("nav.receive"))
    }
}

struct AddressRow: View {
    let label: String
    let address: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(address)
                .font(.system(.footnote, design: .monospaced))
        }
    }
}
#endif
