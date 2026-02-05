import Foundation
import NYXCore

public enum SwapError: Error {
    case unsupported
    case missingApiKey
    case invalidResponse
}

public struct SwapQuote: Codable, Equatable {
    public let fromToken: String
    public let toToken: String
    public let amount: String
    public let estimatedGas: String?
}

public protocol SwapService {
    func quote(fromToken: String, toToken: String, amount: String) async throws -> SwapQuote
}

@available(macOS 10.15, iOS 13.0, *)
public final class ZeroXSwapService: SwapService {
    private let apiKey: String
    private let endpoint: URL

    public init(apiKey: String, endpoint: URL = URL(string: "https://api.0x.org")!) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    public func quote(fromToken: String, toToken: String, amount: String) async throws -> SwapQuote {
        guard !apiKey.isEmpty else { throw SwapError.missingApiKey }
        var components = URLComponents(url: endpoint.appendingPathComponent("swap/v1/quote"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "sellToken", value: fromToken),
            URLQueryItem(name: "buyToken", value: toToken),
            URLQueryItem(name: "sellAmount", value: amount)
        ]
        guard let url = components?.url else { throw SwapError.invalidResponse }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "0x-api-key")
        let (data, _) = try await URLSession.shared.data(for: request)
        struct Response: Decodable { let buyAmount: String; let gas: String? }
        let res = try JSONDecoder().decode(Response.self, from: data)
        return SwapQuote(fromToken: fromToken, toToken: toToken, amount: res.buyAmount, estimatedGas: res.gas)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public final class JupiterSwapService: SwapService {
    private let apiKey: String
    private let endpoint: URL

    public init(apiKey: String, endpoint: URL = URL(string: "https://quote-api.jup.ag")!) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    public func quote(fromToken: String, toToken: String, amount: String) async throws -> SwapQuote {
        guard !apiKey.isEmpty else { throw SwapError.missingApiKey }
        var components = URLComponents(url: endpoint.appendingPathComponent("v6/quote"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "inputMint", value: fromToken),
            URLQueryItem(name: "outputMint", value: toToken),
            URLQueryItem(name: "amount", value: amount)
        ]
        guard let url = components?.url else { throw SwapError.invalidResponse }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        let (data, _) = try await URLSession.shared.data(for: request)
        struct Response: Decodable { let outAmount: String }
        let res = try JSONDecoder().decode(Response.self, from: data)
        return SwapQuote(fromToken: fromToken, toToken: toToken, amount: res.outAmount, estimatedGas: nil)
    }
}
