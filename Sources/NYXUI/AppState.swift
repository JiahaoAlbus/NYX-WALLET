import Foundation
import NYXCore
import NYXSecurity
import NYXChains
import NYXRisk

#if os(iOS)
@MainActor
public final class AppState: ObservableObject {
    @Published public var isInitialized: Bool = false
    @Published public var lastError: String?
    public let vault = SecureVault()

    public let planner: TransactionPlanner
    public let config: AppConfig
    public let nodeManager: NodeManager
    public let serviceConfig: ServiceConfig
    public let settingsStore: SettingsStore
    @Published public var localizer: Localizer
    public let keyManager: KeyManager
    @Published public var addresses: WalletAddresses?
    public let transactionService: TransactionService

    public init() {
        self.settingsStore = SettingsStore()
        let env = settingsStore.loadEnvironment()
        let networkEnv: NetworkEnvironment = env == .testnet ? .testnet : .mainnet
        self.config = AppConfig.defaultThirdParty(environment: networkEnv)
        self.nodeManager = NodeManager(environment: config.environment, store: DefaultNodeStore(), options: Dictionary(grouping: config.nodeOptions, by: { $0.chainId }))
        self.serviceConfig = ServiceConfig.defaultKeys()
        self.localizer = Localizer(language: settingsStore.loadLanguage())
        self.keyManager = KeyManager()
        let feePolicy = FeePolicy(serviceFeeRate: 0.015, showServiceFee: true)
        let feeCalculator = FeeCalculator(feePolicy: feePolicy)
        let phishingDetector = LocalListPhishingDetector(denylist: [])
        let riskEngine = DefaultRiskEngine(phishingDetector: phishingDetector)

        let recipients = FeeRecipientRegistry.defaultConfig()
        let recipientMap = Dictionary(uniqueKeysWithValues: recipients.map { ($0.chainId, $0) })

        let adapters: [String: ChainAdapter] = [
            ChainRegistry.ethereum.id: EVMAdapter(chain: ChainRegistry.ethereum, feeRecipient: recipientMap[ChainRegistry.ethereum.id]!),
            ChainRegistry.bnb.id: EVMAdapter(chain: ChainRegistry.bnb, feeRecipient: recipientMap[ChainRegistry.bnb.id]!),
            ChainRegistry.bitcoin.id: BTCAdapter(chain: ChainRegistry.bitcoin, feeRecipient: recipientMap[ChainRegistry.bitcoin.id]!),
            ChainRegistry.solana.id: SolanaAdapter(chain: ChainRegistry.solana, feeRecipient: recipientMap[ChainRegistry.solana.id]!),
            ChainRegistry.tron.id: TronAdapter(chain: ChainRegistry.tron, feeRecipient: recipientMap[ChainRegistry.tron.id]!)
        ]

        self.planner = DefaultTransactionPlanner(adapters: adapters, riskEngine: riskEngine, feeCalculator: feeCalculator)
        self.transactionService = TransactionService(rpcClient: RPCClient(), signer: WalletCoreSigner(), appConfig: config, vault: vault, feePolicy: feePolicy)
    }

    public func updateEnvironment(_ env: AppEnvironment) {
        settingsStore.saveEnvironment(env)
    }

    public func updateLanguage(_ lang: AppLanguage) {
        settingsStore.saveLanguage(lang)
        localizer.language = lang
    }

    public func unlockWallet() async {
        do {
            let mnemonic = try vault.loadMnemonic(prompt: "Unlock NYX WALLIET")
            let addresses = try keyManager.deriveAddresses(mnemonic: mnemonic, environment: settingsStore.loadEnvironment())
            self.addresses = addresses
            self.isInitialized = true
        } catch {
            self.lastError = error.localizedDescription
        }
    }
}
#else
public final class AppState {
    public init() {}
}
#endif
