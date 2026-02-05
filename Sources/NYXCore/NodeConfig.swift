import Foundation

public struct NodeOption: Codable, Equatable, Hashable {
    public let chainId: String
    public let name: String
    public let url: URL
    public let headers: [String: String]

    public init(chainId: String, name: String, url: URL, headers: [String: String] = [:]) {
        self.chainId = chainId
        self.name = name
        self.url = url
        self.headers = headers
    }
}

public protocol NodeStore {
    func loadSelectedNodeId(for chainId: String) -> String?
    func saveSelectedNodeId(_ nodeId: String, for chainId: String)
    func loadCustomURL(for chainId: String) -> URL?
    func saveCustomURL(_ url: URL?, for chainId: String)
}

public final class DefaultNodeStore: NodeStore {
    private let defaults: UserDefaults
    private let selectedPrefix = "nyx.node.selected."
    private let customPrefix = "nyx.node.custom."

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func loadSelectedNodeId(for chainId: String) -> String? {
        return defaults.string(forKey: selectedPrefix + chainId)
    }

    public func saveSelectedNodeId(_ nodeId: String, for chainId: String) {
        defaults.setValue(nodeId, forKey: selectedPrefix + chainId)
    }

    public func loadCustomURL(for chainId: String) -> URL? {
        guard let raw = defaults.string(forKey: customPrefix + chainId) else {
            return nil
        }
        return URL(string: raw)
    }

    public func saveCustomURL(_ url: URL?, for chainId: String) {
        if let url {
            defaults.setValue(url.absoluteString, forKey: customPrefix + chainId)
        } else {
            defaults.removeObject(forKey: customPrefix + chainId)
        }
    }
}

public final class NodeManager {
    private let environment: NetworkEnvironment
    private let store: NodeStore
    private let options: [String: [NodeOption]]

    public init(environment: NetworkEnvironment, store: NodeStore, options: [String: [NodeOption]]) {
        self.environment = environment
        self.store = store
        self.options = options
    }

    public func availableNodes(for chainId: String) -> [NodeOption] {
        return options[chainId] ?? []
    }

    public func activeNode(for chainId: String) -> NodeOption? {
        let nodes = availableNodes(for: chainId)
        if let custom = store.loadCustomURL(for: chainId) {
            return NodeOption(chainId: chainId, name: "Custom", url: custom)
        }
        if let selectedId = store.loadSelectedNodeId(for: chainId) {
            return nodes.first { $0.name == selectedId }
        }
        return nodes.first
    }
}
