import Foundation
import NYXCore

public protocol RiskEngine {
    func evaluate(draft: TransactionDraft) async -> RiskResult
}

public final class DefaultRiskEngine: RiskEngine {
    private let phishingDetector: PhishingDetector

    public init(phishingDetector: PhishingDetector) {
        self.phishingDetector = phishingDetector
    }

    public func evaluate(draft: TransactionDraft) async -> RiskResult {
        let phishing = await phishingDetector.check(address: draft.to.value)
        if phishing.isPhishing {
            return RiskResult(level: .critical, reasons: phishing.reasons)
        }

        return RiskResult(level: .low, reasons: [])
    }
}

public struct PhishingCheckResult: Codable, Equatable {
    public let isPhishing: Bool
    public let reasons: [String]

    public init(isPhishing: Bool, reasons: [String]) {
        self.isPhishing = isPhishing
        self.reasons = reasons
    }
}

public protocol PhishingDetector {
    func check(address: String) async -> PhishingCheckResult
}

public final class LocalListPhishingDetector: PhishingDetector {
    private let denylist: Set<String>

    public init(denylist: Set<String>) {
        self.denylist = denylist
    }

    public func check(address: String) async -> PhishingCheckResult {
        if denylist.contains(address.lowercased()) {
            return PhishingCheckResult(isPhishing: true, reasons: ["Address flagged by denylist"])
        }
        return PhishingCheckResult(isPhishing: false, reasons: [])
    }
}
