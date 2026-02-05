import Foundation
import NYXCore

@available(macOS 10.15, iOS 13.0, *)
public final class EVMRPC {
    private let client: RPCClient
    private let endpoint: URL
    private let headers: [String: String]

    public init(client: RPCClient, endpoint: URL, headers: [String: String] = [:]) {
        self.client = client
        self.endpoint = endpoint
        self.headers = headers
    }

    public func gasPrice() async throws -> String {
        let req = JSONRPCRequest(id: 1, method: "eth_gasPrice", params: [])
        let body = try JSONEncoder().encode(req)
        return try await client.post(url: endpoint, headers: headers, body: body)
    }

    public func nonce(address: String) async throws -> String {
        let req = JSONRPCRequest(id: 1, method: "eth_getTransactionCount", params: [.string(address), .string("pending")])
        let body = try JSONEncoder().encode(req)
        return try await client.post(url: endpoint, headers: headers, body: body)
    }
}
