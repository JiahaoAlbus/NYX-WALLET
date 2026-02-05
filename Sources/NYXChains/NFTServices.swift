import Foundation
import NYXCore

public enum NFTError: Error {
    case missingApiKey
    case unsupported
}

public struct NFTAsset: Codable, Equatable {
    public let chainId: String
    public let collection: String
    public let tokenId: String
    public let name: String
}

public protocol NFTService {
    func fetchAssets(address: String) async throws -> [NFTAsset]
}

@available(macOS 10.15, iOS 13.0, *)
public final class MagicEdenService: NFTService {
    private let apiKey: String
    private let endpoint: URL

    public init(apiKey: String, endpoint: URL = URL(string: "https://api-mainnet.magiceden.dev")!) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    public func fetchAssets(address: String) async throws -> [NFTAsset] {
        guard !apiKey.isEmpty else { throw NFTError.missingApiKey }
        let url = endpoint.appendingPathComponent("v2/wallets/\(address)/tokens")
        var request = URLRequest(url: url)
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        struct ResponseItem: Decodable { let mintAddress: String?; let name: String?; let collection: String? }
        let items = (try? JSONDecoder().decode([ResponseItem].self, from: data)) ?? []
        return items.map { NFTAsset(chainId: "sol:mainnet", collection: $0.collection ?? "", tokenId: $0.mintAddress ?? "", name: $0.name ?? "") }
    }
}

@available(macOS 10.15, iOS 13.0, *)
public final class OpenSeaService: NFTService {
    private let apiKey: String
    private let endpoint: URL

    public init(apiKey: String, endpoint: URL = URL(string: "https://api.opensea.io")!) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    public func fetchAssets(address: String) async throws -> [NFTAsset] {
        guard !apiKey.isEmpty else { throw NFTError.missingApiKey }
        let url = endpoint.appendingPathComponent("api/v2/chain/ethereum/account/\(address)/nfts")
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        let (data, _) = try await URLSession.shared.data(for: request)
        struct Response: Decodable { let nfts: [Item]
            struct Item: Decodable { let identifier: String; let name: String?; let collection: String? }
        }
        let res = try JSONDecoder().decode(Response.self, from: data)
        return res.nfts.map { NFTAsset(chainId: "evm:1", collection: $0.collection ?? "", tokenId: $0.identifier, name: $0.name ?? "") }
    }
}
