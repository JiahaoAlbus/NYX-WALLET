import Foundation
import BigInt

public enum AmountError: Error {
    case invalidAmount
}

public func decimalToBigUInt(_ decimal: Decimal, decimals: Int) throws -> BigUInt {
    var value = decimal
    var power = Decimal(1)
    for _ in 0..<decimals {
        power *= 10
    }
    value *= power
    let number = NSDecimalNumber(decimal: value)
    let string = number.stringValue
    guard let big = BigUInt(string) else {
        throw AmountError.invalidAmount
    }
    return big
}

public extension BigUInt {
    var data: Data {
        return serialize()
    }
}
