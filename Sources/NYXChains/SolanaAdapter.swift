import Foundation
import NYXCore

public final class SolanaAdapter: ChainAdapter {
    public let chain: Chain
    private let feeRecipient: FeeRecipientConfig

    public init(chain: Chain, feeRecipient: FeeRecipientConfig) {
        self.chain = chain
        self.feeRecipient = feeRecipient
    }

    public func estimateNetworkFee(draft: TransactionDraft) async throws -> Decimal {
        // TODO: Implement fee estimation via Solana RPC.
        return 0.000005
    }

    public func buildRawTransaction(draft: TransactionDraft, serviceFee: Decimal) async throws -> Data {
        // TODO: Implement Solana transfer + fee transfer instruction.
        let payload: [String: String] = [
            "to": draft.to.value,
            "amount": "\(draft.amount)",
            "feeRecipient": feeRecipient.address,
            "serviceFee": "\(serviceFee)"
        ]
        return try JSONSerialization.data(withJSONObject: payload, options: [])
    }
}
