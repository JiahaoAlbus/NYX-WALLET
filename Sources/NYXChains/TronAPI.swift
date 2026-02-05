import Foundation
import NYXCore

@available(macOS 10.15, iOS 13.0, *)
public final class TronAPI {
    private let client: RPCClient
    private let baseURL: URL
    private let headers: [String: String]

    public init(client: RPCClient, baseURL: URL, headers: [String: String]) {
        self.client = client
        self.baseURL = baseURL
        self.headers = headers
    }

    public func nowBlock() async throws -> Data {
        let url = baseURL.appendingPathComponent("wallet/getnowblock")
        return try await client.get(url: url, headers: headers)
    }
}
