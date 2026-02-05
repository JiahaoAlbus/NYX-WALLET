import Foundation
import NYXCore

@available(macOS 10.15, iOS 13.0, *)
public final class SolanaRPC {
    private let client: RPCClient
    private let endpoint: URL

    public init(client: RPCClient, endpoint: URL) {
        self.client = client
        self.endpoint = endpoint
    }

    public func getLatestBlockhash() async throws -> String {
        let req = JSONRPCRequest(id: 1, method: "getLatestBlockhash", params: [.object(["commitment": .string("finalized")])])
        let body = try JSONEncoder().encode(req)
        struct Result: Decodable { let value: Value
            struct Value: Decodable { let blockhash: String }
        }
        let result: Result = try await client.post(url: endpoint, body: body)
        return result.value.blockhash
    }
}
