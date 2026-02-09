import Foundation

public enum AppEnvironment: String, Codable, CaseIterable {
    case mainnet
    case testnet
}

public enum ReleaseChannel: String, Codable, CaseIterable {
    case production
    case staging
}

public enum AppLanguage: String, Codable, CaseIterable {
    case system
    case english
    case chinese
}

public final class SettingsStore {
    private let defaults: UserDefaults
    private let environmentKey = "nyx.app.environment"
    private let languageKey = "nyx.app.language"
    private let releaseChannelKey = "nyx.app.release_channel"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func loadEnvironment() -> AppEnvironment {
        guard let raw = defaults.string(forKey: environmentKey), let env = AppEnvironment(rawValue: raw) else {
            return .mainnet
        }
        return env
    }

    public func saveEnvironment(_ env: AppEnvironment) {
        defaults.setValue(env.rawValue, forKey: environmentKey)
    }

    public func loadLanguage() -> AppLanguage {
        guard let raw = defaults.string(forKey: languageKey), let lang = AppLanguage(rawValue: raw) else {
            return .system
        }
        return lang
    }

    public func saveLanguage(_ lang: AppLanguage) {
        defaults.setValue(lang.rawValue, forKey: languageKey)
    }

    public func loadReleaseChannel() -> ReleaseChannel {
        guard let raw = defaults.string(forKey: releaseChannelKey),
              let channel = ReleaseChannel(rawValue: raw) else {
            return .production
        }
        return channel
    }

    public func saveReleaseChannel(_ channel: ReleaseChannel) {
        defaults.setValue(channel.rawValue, forKey: releaseChannelKey)
    }
}
