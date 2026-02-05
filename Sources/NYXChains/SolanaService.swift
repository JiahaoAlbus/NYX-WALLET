import Foundation
import NYXCore

public final class SolanaService {
    private let client: RPCClient
    private let url: URL

    public init(client: RPCClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func latestBlockhash() async throws -> String {
        let req = JSONRPCRequest(id: 1, method: "getLatestBlockhash", params: [.object(["commitment": .string("finalized")])])
        let body = try JSONEncoder().encode(req)
        struct Result: Decodable { let value: Value
            struct Value: Decodable { let blockhash: String }
        }
        let res: Result = try await client.post(url: url, body: body)
        return res.value.blockhash
    }

    public func sendTransaction(base64: String) async throws -> String {
        let req = JSONRPCRequest(id: 1, method: "sendTransaction", params: [.string(base64)])
        let body = try JSONEncoder().encode(req)
        let result: String = try await client.post(url: url, body: body)
        return result
    }

    public func tokenAccount(owner: String, mint: String) async throws -> String? {
        let params: [EncodableValue] = [
            .string(owner),
            .object(["mint": .string(mint)]),
            .object(["encoding": .string("jsonParsed")])
        ]
        let req = JSONRPCRequest(id: 1, method: "getTokenAccountsByOwner", params: params)
        let body = try JSONEncoder().encode(req)
        struct Result: Decodable {
            let value: [TokenAccount]
            struct TokenAccount: Decodable { let pubkey: String }
        }
        let res: Result = try await client.post(url: url, body: body)
        return res.value.first?.pubkey
    }
}
