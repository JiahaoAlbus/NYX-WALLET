import Foundation
import LocalAuthentication
import Security
import NYXCore

public enum VaultError: Error {
    case secureEnclaveUnavailable
    case keyGenerationFailed
    case keyNotFound
    case encryptionFailed
    case decryptionFailed
    case accessControlFailed
    case biometricFailed
    case storageFailed
    case dataCorrupted
}

#if os(iOS)
public final class SecureVault {
    private let keyTag = "com.nyxwallet.se.keypair"
    private let seedTag = "com.nyxwallet.seed.encrypted"
    private let mnemonicTag = "com.nyxwallet.mnemonic.encrypted"

    public init() {}

    public func isBiometryAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public func generateOrLoadKeyPair() throws -> SecKey {
        if let existing = try loadPrivateKey() {
            return existing
        }
        return try generateKeyPair()
    }

    public func storeSeed(_ seed: Data) throws {
        let privateKey = try generateOrLoadKeyPair()
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw VaultError.keyGenerationFailed
        }

        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw VaultError.encryptionFailed
        }

        var error: Unmanaged<CFError>?
        guard let encrypted = SecKeyCreateEncryptedData(publicKey, algorithm, seed as CFData, &error) as Data? else {
            throw VaultError.encryptionFailed
        }

        let status = storeData(encrypted, tag: seedTag)
        guard status == errSecSuccess else {
            throw VaultError.storageFailed
        }
    }

    public func storeMnemonic(_ phrase: String) throws {
        guard let data = phrase.data(using: .utf8) else {
            throw VaultError.dataCorrupted
        }
        let privateKey = try generateOrLoadKeyPair()
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw VaultError.keyGenerationFailed
        }

        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw VaultError.encryptionFailed
        }

        var error: Unmanaged<CFError>?
        guard let encrypted = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            throw VaultError.encryptionFailed
        }

        let status = storeData(encrypted, tag: mnemonicTag)
        guard status == errSecSuccess else {
            throw VaultError.storageFailed
        }
    }

    public func loadSeed(prompt: String) throws -> Data {
        let privateKey = try authenticatePrivateKey(prompt: prompt)
        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            throw VaultError.decryptionFailed
        }

        guard let encrypted = loadData(tag: seedTag) else {
            throw VaultError.keyNotFound
        }

        var error: Unmanaged<CFError>?
        guard let decrypted = SecKeyCreateDecryptedData(privateKey, algorithm, encrypted as CFData, &error) as Data? else {
            throw VaultError.decryptionFailed
        }

        return decrypted
    }

    public func loadMnemonic(prompt: String) throws -> String {
        let privateKey = try authenticatePrivateKey(prompt: prompt)
        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            throw VaultError.decryptionFailed
        }

        guard let encrypted = loadData(tag: mnemonicTag) else {
            throw VaultError.keyNotFound
        }

        var error: Unmanaged<CFError>?
        guard let decrypted = SecKeyCreateDecryptedData(privateKey, algorithm, encrypted as CFData, &error) as Data? else {
            throw VaultError.decryptionFailed
        }

        guard let phrase = String(data: decrypted, encoding: .utf8) else {
            throw VaultError.dataCorrupted
        }
        return phrase
    }

    public func wipeAll() throws {
        deleteKey(tag: keyTag)
        deleteData(tag: seedTag)
        deleteData(tag: mnemonicTag)
    }

    private func generateKeyPair() throws -> SecKey {
        let accessFlags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            accessFlags = [.privateKeyUsage, .biometryCurrentSet]
        } else {
            accessFlags = [.privateKeyUsage]
        }

        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            accessFlags,
            nil
        )
        guard let accessControl = access else {
            throw VaultError.accessControlFailed
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
                kSecAttrAccessControl as String: accessControl
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw VaultError.secureEnclaveUnavailable
        }
        return privateKey
    }

    private func loadPrivateKey() throws -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let item = item else {
            throw VaultError.keyNotFound
        }
        return (item as! SecKey)
    }

    private func authenticatePrivateKey(prompt: String) throws -> SecKey {
        let context = LAContext()
        context.localizedReason = prompt

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecUseAuthenticationContext as String: context,
            kSecUseOperationPrompt as String: prompt
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let item = item else {
            throw VaultError.biometricFailed
        }
        return (item as! SecKey)
    }

    private func storeData(_ data: Data, tag: String) -> OSStatus {
        deleteData(tag: tag)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]
        return SecItemAdd(query as CFDictionary, nil)
    }

    private func loadData(tag: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return item as? Data
    }

    private func deleteKey(tag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func deleteData(tag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag
        ]
        SecItemDelete(query as CFDictionary)
    }

}
#else
public final class SecureVault {
    public init() {}

    public func isBiometryAvailable() -> Bool { false }
    public func generateOrLoadKeyPair() throws -> SecKey { throw VaultError.secureEnclaveUnavailable }
    public func storeSeed(_ seed: Data) throws { throw VaultError.secureEnclaveUnavailable }
    public func loadSeed(prompt: String) throws -> Data { throw VaultError.secureEnclaveUnavailable }
    public func wipeAll() throws {}
}
#endif
