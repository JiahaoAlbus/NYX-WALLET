import Foundation
import NYXCore

public struct BitcoinUTXO: Decodable {
    public let txid: String
    public let vout: Int
    public let value: Int64
}

public struct BitcoinTxVout: Decodable {
    public let scriptpubkey: String
    public let value: Int64
}

public struct BitcoinTx: Decodable {
    public let vout: [BitcoinTxVout]
}

public final class BitcoinService {
    private let client: RPCClient
    private let baseURL: URL

    public init(client: RPCClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    public func utxos(address: String) async throws -> [BitcoinUTXO] {
        let url = baseURL.appendingPathComponent("address/")
            .appendingPathComponent(address)
            .appendingPathComponent("utxo")
        let data = try await client.get(url: url)
        return try JSONDecoder().decode([BitcoinUTXO].self, from: data)
    }

    public func tx(txid: String) async throws -> BitcoinTx {
        let url = baseURL.appendingPathComponent("tx/")
            .appendingPathComponent(txid)
        let data = try await client.get(url: url)
        return try JSONDecoder().decode(BitcoinTx.self, from: data)
    }

    public func feeRate() async throws -> Int64 {
        let url = baseURL.appendingPathComponent("fee-estimates")
        let data = try await client.get(url: url)
        let map = try JSONDecoder().decode([String: Double].self, from: data)
        return Int64(map["1"] ?? 2)
    }

    public func broadcast(txHex: String) async throws -> String {
        let url = baseURL.appendingPathComponent("tx")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = txHex.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RPCError.invalidResponse
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
