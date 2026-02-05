import Foundation
import NYXCore

public struct ChainRegistry {
    public static let ethereum = Chain(id: "evm:1", name: "Ethereum", kind: .evm, nativeSymbol: "ETH")
    public static let bnb = Chain(id: "evm:56", name: "BNB Smart Chain", kind: .evm, nativeSymbol: "BNB")
    public static let bitcoin = Chain(id: "btc:mainnet", name: "Bitcoin", kind: .bitcoin, nativeSymbol: "BTC")
    public static let solana = Chain(id: "sol:mainnet", name: "Solana", kind: .solana, nativeSymbol: "SOL")
    public static let tron = Chain(id: "tron:mainnet", name: "TRON", kind: .tron, nativeSymbol: "TRX")

    public static let all: [Chain] = [ethereum, bnb, bitcoin, solana, tron]
}

public struct FeeRecipientRegistry {
    public static func defaultConfig() -> [FeeRecipientConfig] {
        return [
            FeeRecipientConfig(chainId: ChainRegistry.ethereum.id, address: "0x0Aa313fCE773786C8425a13B96DB64205c5edCBc"),
            FeeRecipientConfig(chainId: ChainRegistry.bnb.id, address: "0x0Aa313fCE773786C8425a13B96DB64205c5edCBc"),
            FeeRecipientConfig(chainId: ChainRegistry.bitcoin.id, address: "bc1q3tqcmsal6lmjjulvqf3gfzcf8fw4mgaw0tvgs7"),
            FeeRecipientConfig(chainId: ChainRegistry.solana.id, address: "3CJR8eHSzrtGuJJLJ1HsE7gB7Sz6qEVSLkz3joAga3mf"),
            FeeRecipientConfig(chainId: ChainRegistry.tron.id, address: "TEjAMnvTPGQKmAra8BoUiXht6C6U9Untrh")
        ]
    }
}
