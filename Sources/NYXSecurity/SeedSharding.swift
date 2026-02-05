import Foundation

public enum ShardingError: Error {
    case invalidThreshold
    case insufficientShards
    case inconsistentShardLengths
}

public struct SeedShard: Codable, Equatable {
    public let index: Int
    public let data: Data

    public init(index: Int, data: Data) {
        self.index = index
        self.data = data
    }
}

public struct SeedSharder {
    public init() {}

    public func split(seed: Data, threshold: Int, shares: Int) throws -> [SeedShard] {
        guard threshold >= 2, shares >= threshold else {
            throw ShardingError.invalidThreshold
        }
        var shards: [SeedShard] = []
        let seedBytes = [UInt8](seed)

        // Pre-generate random coefficients for each byte
        var polys: [[UInt8]] = []
        polys.reserveCapacity(seedBytes.count)
        for byte in seedBytes {
            var coeffs: [UInt8] = [byte]
            for _ in 1..<threshold {
                coeffs.append(UInt8.random(in: 0...255))
            }
            polys.append(coeffs)
        }

        for x in 1...shares {
            var shardBytes: [UInt8] = []
            shardBytes.reserveCapacity(seedBytes.count)
            for coeffs in polys {
                let y = evaluatePolynomial(coeffs: coeffs, x: UInt8(x))
                shardBytes.append(y)
            }
            shards.append(SeedShard(index: x, data: Data(shardBytes)))
        }
        return shards
    }

    public func combine(shards: [SeedShard]) throws -> Data {
        guard shards.count >= 2 else {
            throw ShardingError.insufficientShards
        }
        let lengths = Set(shards.map { $0.data.count })
        guard lengths.count == 1, let length = lengths.first else {
            throw ShardingError.inconsistentShardLengths
        }

        let points = shards.map { (x: UInt8($0.index), y: [UInt8]($0.data)) }
        var result: [UInt8] = Array(repeating: 0, count: length)

        for i in 0..<length {
            var value: UInt8 = 0
            for j in 0..<points.count {
                let xj = points[j].x
                let yj = points[j].y[i]
                var num: UInt8 = 1
                var den: UInt8 = 1
                for m in 0..<points.count where m != j {
                    let xm = points[m].x
                    num = gfMul(num, xm)
                    den = gfMul(den, gfAdd(xm, xj))
                }
                let lagrange = gfMul(num, gfInv(den))
                value = gfAdd(value, gfMul(yj, lagrange))
            }
            result[i] = value
        }
        return Data(result)
    }
}

private func evaluatePolynomial(coeffs: [UInt8], x: UInt8) -> UInt8 {
    var y: UInt8 = 0
    var power: UInt8 = 1
    for c in coeffs {
        y = gfAdd(y, gfMul(c, power))
        power = gfMul(power, x)
    }
    return y
}

@inline(__always) private func gfAdd(_ a: UInt8, _ b: UInt8) -> UInt8 {
    return a ^ b
}

private func gfMul(_ a: UInt8, _ b: UInt8) -> UInt8 {
    var a = a
    var b = b
    var p: UInt8 = 0
    for _ in 0..<8 {
        if (b & 1) != 0 {
            p ^= a
        }
        let hiBit = a & 0x80
        a <<= 1
        if hiBit != 0 {
            a ^= 0x1b
        }
        b >>= 1
    }
    return p
}

private func gfPow(_ a: UInt8, _ n: Int) -> UInt8 {
    var result: UInt8 = 1
    var base = a
    var exp = n
    while exp > 0 {
        if exp & 1 == 1 {
            result = gfMul(result, base)
        }
        base = gfMul(base, base)
        exp >>= 1
    }
    return result
}

private func gfInv(_ a: UInt8) -> UInt8 {
    // a^(254) in GF(256)
    return gfPow(a, 254)
}
