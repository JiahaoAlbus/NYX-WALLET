import Foundation

public struct WalletAddresses: Codable, Equatable {
    public let evm: String
    public let bnb: String
    public let btc: String
    public let sol: String
    public let tron: String

    public init(evm: String, bnb: String, btc: String, sol: String, tron: String) {
        self.evm = evm
        self.bnb = bnb
        self.btc = btc
        self.sol = sol
        self.tron = tron
    }
}
