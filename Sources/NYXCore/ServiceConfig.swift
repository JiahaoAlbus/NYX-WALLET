import Foundation

public struct ServiceConfig {
    public let zeroXApiKey: String
    public let jupiterApiKey: String
    public let magicEdenApiKey: String
    public let openSeaApiKey: String

    public init(zeroXApiKey: String, jupiterApiKey: String, magicEdenApiKey: String, openSeaApiKey: String) {
        self.zeroXApiKey = zeroXApiKey
        self.jupiterApiKey = jupiterApiKey
        self.magicEdenApiKey = magicEdenApiKey
        self.openSeaApiKey = openSeaApiKey
    }

    public static func defaultKeys() -> ServiceConfig {
        return ServiceConfig(
            zeroXApiKey: APIKeys.zeroX,
            jupiterApiKey: APIKeys.jupiter,
            magicEdenApiKey: APIKeys.magicEden,
            openSeaApiKey: APIKeys.openSea
        )
    }

    public static func forChannel(_ channel: ReleaseChannel) -> ServiceConfig {
        switch channel {
        case .production:
            return defaultKeys()
        case .staging:
            return ServiceConfig(
                zeroXApiKey: APIKeys.zeroXStaging,
                jupiterApiKey: APIKeys.jupiterStaging,
                magicEdenApiKey: APIKeys.magicEdenStaging,
                openSeaApiKey: APIKeys.openSeaStaging
            )
        }
    }
}
