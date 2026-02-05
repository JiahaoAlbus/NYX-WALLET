import Foundation
import NYXCore

public final class TronService {
    private let client: RPCClient
    private let url: URL
    private let headers: [String: String]

    public init(client: RPCClient, url: URL, headers: [String: String]) {
        self.client = client
        self.url = url
        self.headers = headers
    }

    public func getNowBlock() async throws -> TronBlockResponse {
        let endpoint = url.appendingPathComponent("wallet/getnowblock")
        let data = try await client.get(url: endpoint, headers: headers)
        return try JSONDecoder().decode(TronBlockResponse.self, from: data)
    }

    public func broadcast(hex: String) async throws -> TronBroadcastResponse {
        let endpoint = url.appendingPathComponent("wallet/broadcasthex")
        let body = try JSONSerialization.data(withJSONObject: ["transaction": hex], options: [])
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RPCError.invalidResponse
        }
        return try JSONDecoder().decode(TronBroadcastResponse.self, from: data)
    }

    public func broadcast(json: String) async throws -> TronBroadcastResponse {
        let endpoint = url.appendingPathComponent("wallet/broadcasttransaction")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = json.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RPCError.invalidResponse
        }
        return try JSONDecoder().decode(TronBroadcastResponse.self, from: data)
    }
}

public struct TronBlockResponse: Decodable {
    public let blockID: String
    public let blockHeader: TronBlockHeaderJSON

    enum CodingKeys: String, CodingKey {
        case blockID = "blockID"
        case blockHeader = "block_header"
    }
}

public struct TronBlockHeaderJSON: Decodable {
    public let rawData: TronBlockHeaderRaw

    enum CodingKeys: String, CodingKey {
        case rawData = "raw_data"
    }
}

public struct TronBlockHeaderRaw: Decodable {
    public let number: Int64
    public let txTrieRoot: String
    public let parentHash: String
    public let witnessAddress: String
    public let timestamp: Int64
    public let version: Int64

    enum CodingKeys: String, CodingKey {
        case number
        case txTrieRoot = "txTrieRoot"
        case parentHash = "parentHash"
        case witnessAddress = "witnessAddress"
        case timestamp
        case version
    }
}

public struct TronBroadcastResponse: Decodable {
    public let result: Bool
    public let txid: String?
    public let code: String?
    public let message: String?
}
