import Foundation

public enum NetworkEnvironment: String, Codable, CaseIterable {
    case mainnet
    case testnet
}

public struct RPCConfig: Codable, Equatable {
    public let chainId: String
    public let rpcURL: URL
    public let headers: [String: String]

    public init(chainId: String, rpcURL: URL, headers: [String: String] = [:]) {
        self.chainId = chainId
        self.rpcURL = rpcURL
        self.headers = headers
    }
}

public struct AppConfig: Codable, Equatable {
    public let environment: NetworkEnvironment
    public let rpcConfigs: [RPCConfig]
    public let nodeOptions: [NodeOption]

    public init(environment: NetworkEnvironment, rpcConfigs: [RPCConfig], nodeOptions: [NodeOption]) {
        self.environment = environment
        self.rpcConfigs = rpcConfigs
        self.nodeOptions = nodeOptions
    }

    public static func defaultThirdParty(environment: NetworkEnvironment) -> AppConfig {
        switch environment {
        case .mainnet:
            return AppConfig(environment: .mainnet, rpcConfigs: [
                RPCConfig(chainId: "evm:1", rpcURL: URL(string: "https://ethereum-rpc.publicnode.com")!),
                RPCConfig(chainId: "evm:56", rpcURL: URL(string: "https://bsc-rpc.publicnode.com")!),
                RPCConfig(chainId: "btc:mainnet", rpcURL: URL(string: "https://blockstream.info/api/")!),
                RPCConfig(chainId: "sol:mainnet", rpcURL: URL(string: "https://api.mainnet.solana.com")!),
                RPCConfig(chainId: "tron:mainnet", rpcURL: URL(string: "https://api.trongrid.io")!, headers: [
                    "TRON-PRO-API-KEY": APIKeys.tronGrid
                ])
            ], nodeOptions: [
                NodeOption(chainId: "evm:1", name: "PublicNode", url: URL(string: "https://ethereum-rpc.publicnode.com")!),
                NodeOption(chainId: "evm:56", name: "PublicNode", url: URL(string: "https://bsc-rpc.publicnode.com")!),
                NodeOption(chainId: "btc:mainnet", name: "Blockstream", url: URL(string: "https://blockstream.info/api/")!),
                NodeOption(chainId: "sol:mainnet", name: "Solana", url: URL(string: "https://api.mainnet.solana.com")!),
                NodeOption(chainId: "tron:mainnet", name: "TronGrid", url: URL(string: "https://api.trongrid.io")!, headers: [
                    "TRON-PRO-API-KEY": APIKeys.tronGrid
                ])
            ])
        case .testnet:
            return AppConfig(environment: .testnet, rpcConfigs: [
                RPCConfig(chainId: "evm:11155111", rpcURL: URL(string: "https://ethereum-sepolia-rpc.publicnode.com")!),
                RPCConfig(chainId: "evm:97", rpcURL: URL(string: "https://bsc-testnet-rpc.publicnode.com")!),
                RPCConfig(chainId: "btc:testnet", rpcURL: URL(string: "https://blockstream.info/testnet/api/")!),
                RPCConfig(chainId: "sol:devnet", rpcURL: URL(string: "https://api.devnet.solana.com")!),
                RPCConfig(chainId: "tron:shasta", rpcURL: URL(string: "https://api.shasta.trongrid.io")!, headers: [
                    "TRON-PRO-API-KEY": APIKeys.tronGrid
                ])
            ], nodeOptions: [
                NodeOption(chainId: "evm:11155111", name: "PublicNode", url: URL(string: "https://ethereum-sepolia-rpc.publicnode.com")!),
                NodeOption(chainId: "evm:97", name: "PublicNode", url: URL(string: "https://bsc-testnet-rpc.publicnode.com")!),
                NodeOption(chainId: "btc:testnet", name: "Blockstream", url: URL(string: "https://blockstream.info/testnet/api/")!),
                NodeOption(chainId: "sol:devnet", name: "Solana", url: URL(string: "https://api.devnet.solana.com")!),
                NodeOption(chainId: "tron:shasta", name: "TronGrid", url: URL(string: "https://api.shasta.trongrid.io")!, headers: [
                    "TRON-PRO-API-KEY": APIKeys.tronGrid
                ])
            ])
        }
    }
}
