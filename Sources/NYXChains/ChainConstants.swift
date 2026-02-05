import Foundation

public struct TokenConfig {
    public let symbol: String
    public let contract: String
    public let decimals: Int
}

public struct ChainConstants {
    public static let usdtEthereum = TokenConfig(symbol: "USDT", contract: "0xdAC17F958D2ee523a2206206994597C13D831ec7", decimals: 6)
    public static let usdtBnb = TokenConfig(symbol: "USDT", contract: "0x55d398326f99059fF775485246999027B3197955", decimals: 18)
    public static let usdtTron = TokenConfig(symbol: "USDT", contract: "TXLAQ63Xg1NAzckPwKHvzw7CSEmLMEqcdj", decimals: 6)
    public static let usdtSol = TokenConfig(symbol: "USDT", contract: "Es9vMFrzaCERz5o8X7ZsGLS2U2Yq1gBL7zNQih1xD6ZX", decimals: 6)
}
