import XCTest
import NYXSecurity

final class SeedShardingTests: XCTestCase {
    func testSplitAndCombine() throws {
        let seed = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let sharder = SeedSharder()
        let shards = try sharder.split(seed: seed, threshold: 3, shares: 5)
        let recovered = try sharder.combine(shards: Array(shards.prefix(3)))
        XCTAssertEqual(seed, recovered)
    }
}
