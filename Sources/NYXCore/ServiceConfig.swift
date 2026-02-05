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
}
