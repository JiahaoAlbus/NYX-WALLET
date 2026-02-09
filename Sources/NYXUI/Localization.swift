import Foundation
import SwiftUI
import NYXCore

#if os(iOS)
public final class Localizer: ObservableObject {
    @Published public var language: AppLanguage

    public init(language: AppLanguage) {
        self.language = language
    }

    public func text(_ key: String) -> String {
        switch language {
        case .system:
            return key
        case .english:
            return english[key] ?? key
        case .chinese:
            return chinese[key] ?? key
        }
    }

    private let english: [String: String] = [
        "app.title": "NYX WALLIET",
        "wallet.secure": "Secure Web3 Wallet",
        "wallet.service_fee": "Service fee: 1.5%",
        "nav.swap": "Swap",
        "nav.nft": "NFT",
        "nav.buy": "Buy Crypto",
        "nav.dapp": "DApp",
        "nav.nodes": "Node Settings",
        "nav.settings": "Settings",
        "nav.wallet": "Wallet",
        "nav.receive": "Receive",
        "nav.send": "Send",
        "onboarding.title": "Create or import a wallet",
        "onboarding.subtitle": "Your keys never leave this device.",
        "button.create": "Create Wallet",
        "button.import": "Import Wallet",
        "button.lock": "Lock Wallet",
        "button.unlock": "Unlock Wallet",
        "settings.language": "Language",
        "settings.environment": "Environment",
        "settings.mainnet": "Mainnet",
        "settings.testnet": "Testnet",
        "settings.release_channel": "Release Channel",
        "settings.production": "Production",
        "settings.staging": "Staging",
        "settings.system": "System",
        "settings.english": "English",
        "settings.chinese": "Chinese"
    ]

    private let chinese: [String: String] = [
        "app.title": "NYX WALLIET",
        "wallet.secure": "安全的 Web3 钱包",
        "wallet.service_fee": "服务费：1.5%",
        "nav.swap": "兑换",
        "nav.nft": "NFT",
        "nav.buy": "买币",
        "nav.dapp": "DApp",
        "nav.nodes": "节点设置",
        "nav.settings": "设置",
        "nav.wallet": "钱包",
        "nav.receive": "收款",
        "nav.send": "转账",
        "onboarding.title": "创建或导入钱包",
        "onboarding.subtitle": "私钥仅存于本机，不会离开设备。",
        "button.create": "创建钱包",
        "button.import": "导入钱包",
        "button.lock": "锁定钱包",
        "button.unlock": "解锁钱包",
        "settings.language": "语言",
        "settings.environment": "环境",
        "settings.mainnet": "主网",
        "settings.testnet": "测试网",
        "settings.release_channel": "发布通道",
        "settings.production": "生产",
        "settings.staging": "预发",
        "settings.system": "系统",
        "settings.english": "英文",
        "settings.chinese": "中文"
    ]
}
#else
public final class Localizer {
    public var language: AppLanguage
    public init(language: AppLanguage) { self.language = language }
    public func text(_ key: String) -> String { key }
}
#endif
