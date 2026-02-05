import Foundation
import NYXCore
import NYXSecurity
import NYXRisk

public enum ChainError: Error {
    case unsupportedChain
    case missingFeeRecipient
}

public protocol ChainAdapter {
    var chain: Chain { get }
    func estimateNetworkFee(draft: TransactionDraft) async throws -> Decimal
    func buildRawTransaction(draft: TransactionDraft, serviceFee: Decimal) async throws -> Data
}

public struct FeeRecipientConfig: Codable, Equatable {
    public let chainId: String
    public let address: String

    public init(chainId: String, address: String) {
        self.chainId = chainId
        self.address = address
    }
}

public final class FeeCalculator {
    private let feePolicy: FeePolicy

    public init(feePolicy: FeePolicy) {
        self.feePolicy = feePolicy
    }

    public func calculate(networkFee: Decimal, amount: Decimal) -> FeeBreakdown {
        let serviceFee = (amount * feePolicy.serviceFeeRate).rounded(scale: 8)
        let total = networkFee + serviceFee
        return FeeBreakdown(networkFee: networkFee, serviceFee: serviceFee, total: total)
    }
}

public struct TransactionPlan: Codable, Equatable {
    public let draft: TransactionDraft
    public let simulation: SimulationResult
    public let risk: RiskResult

    public init(draft: TransactionDraft, simulation: SimulationResult, risk: RiskResult) {
        self.draft = draft
        self.simulation = simulation
        self.risk = risk
    }
}

public protocol TransactionPlanner {
    func plan(draft: TransactionDraft) async throws -> TransactionPlan
}

public final class DefaultTransactionPlanner: TransactionPlanner {
    private let adapters: [String: ChainAdapter]
    private let riskEngine: RiskEngine
    private let feeCalculator: FeeCalculator

    public init(adapters: [String: ChainAdapter], riskEngine: RiskEngine, feeCalculator: FeeCalculator) {
        self.adapters = adapters
        self.riskEngine = riskEngine
        self.feeCalculator = feeCalculator
    }

    public func plan(draft: TransactionDraft) async throws -> TransactionPlan {
        guard let adapter = adapters[draft.chainId] else {
            throw ChainError.unsupportedChain
        }
        let networkFee = try await adapter.estimateNetworkFee(draft: draft)
        let fee = feeCalculator.calculate(networkFee: networkFee, amount: draft.amount)
        let simulation = SimulationResult(willSucceed: true, warnings: [], estimatedFee: fee)
        let risk = await riskEngine.evaluate(draft: draft)
        return TransactionPlan(draft: draft, simulation: simulation, risk: risk)
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .bankers)
        return result
    }
}
