import Foundation
import NYXCore

#if os(iOS)
import WalletCore

public enum KeyManagerError: Error {
    case invalidMnemonic
    case keyDerivationFailed
}

public final class KeyManager {
    public init() {}

    public func generateMnemonic(strength: Int = 128) throws -> String {
        guard let wallet = HDWallet(strength: Int32(strength), passphrase: "") else {
            throw KeyManagerError.keyDerivationFailed
        }
        return wallet.mnemonic
    }

    public func deriveAddresses(mnemonic: String, environment: AppEnvironment) throws -> WalletAddresses {
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            throw KeyManagerError.invalidMnemonic
        }

        let evm = wallet.getAddressForCoin(coin: .ethereum)
        let bnb = wallet.getAddressForCoin(coin: .smartChain)
        let btc: String
        if environment == .testnet {
            btc = wallet.getAddressDerivation(coin: .bitcoin, derivation: .bitcoinTestnet)
        } else {
            btc = wallet.getAddressDerivation(coin: .bitcoin, derivation: .bitcoinSegwit)
        }
        let sol = wallet.getAddressForCoin(coin: .solana)
        let tron = wallet.getAddressForCoin(coin: .tron)

        return WalletAddresses(evm: evm, bnb: bnb, btc: btc, sol: sol, tron: tron)
    }
}
#else
public enum KeyManagerError: Error {
    case invalidMnemonic
    case keyDerivationFailed
}

public final class KeyManager {
    public init() {}
    public func generateMnemonic(strength: Int = 128) throws -> String { "" }
    public func deriveAddresses(mnemonic: String, environment: AppEnvironment) throws -> WalletAddresses {
        return WalletAddresses(evm: "", bnb: "", btc: "", sol: "", tron: "")
    }
}
#endif
