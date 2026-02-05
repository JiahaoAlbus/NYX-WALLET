import Foundation
import NYXCore

public enum RPCError: Error {
    case invalidURL
    case transportError
    case invalidResponse
    case serverError(String)
    case decodingError
}

public struct JSONRPCRequest: Encodable {
    public let jsonrpc: String = "2.0"
    public let id: Int
    public let method: String
    public let params: [EncodableValue]

    public init(id: Int, method: String, params: [EncodableValue]) {
        self.id = id
        self.method = method
        self.params = params
    }
}

public struct JSONRPCResponse<Result: Decodable>: Decodable {
    public let jsonrpc: String?
    public let id: Int?
    public let result: Result?
    public let error: JSONRPCError?
}

public struct JSONRPCError: Decodable {
    public let code: Int
    public let message: String
}

public enum EncodableValue: Encodable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case object([String: EncodableValue])
    case array([EncodableValue])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}

@available(macOS 10.15, iOS 13.0, *)
public final class RPCClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func post<Result: Decodable>(
        url: URL,
        headers: [String: String] = [:],
        body: Data
    ) async throws -> Result {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, response) = try await data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RPCError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(JSONRPCResponse<Result>.self, from: data)
        if let error = decoded.error {
            throw RPCError.serverError(error.message)
        }
        guard let result = decoded.result else {
            throw RPCError.decodingError
        }
        return result
    }

    public func get(url: URL, headers: [String: String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, response) = try await data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RPCError.invalidResponse
        }
        return data
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data, let response else {
                    continuation.resume(throwing: RPCError.invalidResponse)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
