import Foundation
import BigInt
import NYXCore

public final class EVMService {
    private let client: RPCClient
    private let url: URL

    public init(client: RPCClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func nonce(address: String) async throws -> BigUInt {
        let req = JSONRPCRequest(id: 1, method: "eth_getTransactionCount", params: [.string(address), .string("pending")])
        let body = try JSONEncoder().encode(req)
        let result: String = try await client.post(url: url, body: body)
        return BigUInt(result.stripHexPrefix(), radix: 16) ?? 0
    }

    public func gasPrice() async throws -> BigUInt {
        let req = JSONRPCRequest(id: 1, method: "eth_gasPrice", params: [])
        let body = try JSONEncoder().encode(req)
        let result: String = try await client.post(url: url, body: body)
        return BigUInt(result.stripHexPrefix(), radix: 16) ?? 0
    }

    public func estimateGas(from: String, to: String, value: BigUInt, data: String?) async throws -> BigUInt {
        var obj: [String: EncodableValue] = [
            "from": .string(from),
            "to": .string(to),
            "value": .string("0x" + value.serialize().toHexString())
        ]
        if let data { obj["data"] = .string(data) }
        let req = JSONRPCRequest(id: 1, method: "eth_estimateGas", params: [.object(obj)])
        let body = try JSONEncoder().encode(req)
        let result: String = try await client.post(url: url, body: body)
        return BigUInt(result.stripHexPrefix(), radix: 16) ?? 21000
    }

    public func sendRawTransaction(_ raw: Data) async throws -> String {
        let hex = "0x" + raw.toHexString()
        let req = JSONRPCRequest(id: 1, method: "eth_sendRawTransaction", params: [.string(hex)])
        let body = try JSONEncoder().encode(req)
        let result: String = try await client.post(url: url, body: body)
        return result
    }
}

private extension String {
    func stripHexPrefix() -> String {
        if hasPrefix("0x") { return String(dropFirst(2)) }
        return self
    }
}

private extension Data {
    func toHexString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
