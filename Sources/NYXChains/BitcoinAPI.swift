import Foundation
import NYXCore

@available(macOS 10.15, iOS 13.0, *)
public final class BitcoinAPI {
    private let client: RPCClient
    private let baseURL: URL

    public init(client: RPCClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    public func feeEstimates() async throws -> [String: Double] {
        let url = baseURL.appendingPathComponent("fee-estimates")
        let data = try await client.get(url: url)
        return try JSONDecoder().decode([String: Double].self, from: data)
    }
}
