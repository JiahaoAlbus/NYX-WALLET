import Foundation

public enum ChainKind: String, Codable, CaseIterable {
    case evm
    case bitcoin
    case solana
    case tron
}

public struct Chain: Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let kind: ChainKind
    public let nativeSymbol: String

    public init(id: String, name: String, kind: ChainKind, nativeSymbol: String) {
        self.id = id
        self.name = name
        self.kind = kind
        self.nativeSymbol = nativeSymbol
    }
}

public struct Asset: Codable, Equatable, Hashable {
    public let chainId: String
    public let symbol: String
    public let contractAddress: String?
    public let decimals: Int

    public init(chainId: String, symbol: String, contractAddress: String?, decimals: Int) {
        self.chainId = chainId
        self.symbol = symbol
        self.contractAddress = contractAddress
        self.decimals = decimals
    }
}

public struct Address: Codable, Equatable, Hashable {
    public let value: String
    public init(_ value: String) {
        self.value = value
    }
}

public struct Money: Codable, Equatable, Hashable {
    public let amount: Decimal
    public let asset: Asset

    public init(amount: Decimal, asset: Asset) {
        self.amount = amount
        self.asset = asset
    }
}

public enum TransactionDirection: String, Codable {
    case send
    case receive
}

public struct TransactionDraft: Codable, Equatable {
    public let chainId: String
    public let asset: Asset
    public let from: Address
    public let to: Address
    public let amount: Decimal
    public let memo: String?

    public init(chainId: String, asset: Asset, from: Address, to: Address, amount: Decimal, memo: String? = nil) {
        self.chainId = chainId
        self.asset = asset
        self.from = from
        self.to = to
        self.amount = amount
        self.memo = memo
    }
}

public struct FeeBreakdown: Codable, Equatable {
    public let networkFee: Decimal
    public let serviceFee: Decimal
    public let total: Decimal

    public init(networkFee: Decimal, serviceFee: Decimal, total: Decimal) {
        self.networkFee = networkFee
        self.serviceFee = serviceFee
        self.total = total
    }
}

public struct FeePolicy: Codable, Equatable {
    public let serviceFeeRate: Decimal
    public let showServiceFee: Bool

    public init(serviceFeeRate: Decimal, showServiceFee: Bool) {
        self.serviceFeeRate = serviceFeeRate
        self.showServiceFee = showServiceFee
    }
}

public struct SimulationResult: Codable, Equatable {
    public let willSucceed: Bool
    public let warnings: [String]
    public let estimatedFee: FeeBreakdown

    public init(willSucceed: Bool, warnings: [String], estimatedFee: FeeBreakdown) {
        self.willSucceed = willSucceed
        self.warnings = warnings
        self.estimatedFee = estimatedFee
    }
}

public enum RiskLevel: String, Codable {
    case low
    case medium
    case high
    case critical
}

public struct RiskResult: Codable, Equatable {
    public let level: RiskLevel
    public let reasons: [String]

    public init(level: RiskLevel, reasons: [String]) {
        self.level = level
        self.reasons = reasons
    }
}
