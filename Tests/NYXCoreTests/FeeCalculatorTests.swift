import XCTest
import NYXCore
import NYXChains

final class FeeCalculatorTests: XCTestCase {
    func testServiceFeeCalculation() throws {
        let policy = FeePolicy(serviceFeeRate: 0.015, showServiceFee: true)
        let calculator = FeeCalculator(feePolicy: policy)
        let fee = calculator.calculate(networkFee: 0.001, amount: 10)
        XCTAssertEqual(fee.serviceFee, 0.15)
        XCTAssertEqual(fee.total, 0.151)
    }
}
