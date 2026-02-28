// KeychainService.swift
// Stores and retrieves access + refresh tokens from the iOS Keychain.
// Uses Apple's Security framework directly (no third-party dependency needed for Phase 0).
// NOTE: If KeychainAccess SPM package is added (Week 1 task), replace the raw
//       Security calls below with KeychainAccess equivalents (same public API).

import Foundation
import Security

final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    // MARK: - Keys

    private enum Key: String {
        case accessToken  = "com.videoslacker.accessToken"
        case refreshToken = "com.videoslacker.refreshToken"
    }

    // MARK: - Public API

    var accessToken: String? {
        get { load(key: .accessToken) }
        set { if let v = newValue { save(v, key: .accessToken) } else { delete(key: .accessToken) } }
    }

    var refreshToken: String? {
        get { load(key: .refreshToken) }
        set { if let v = newValue { save(v, key: .refreshToken) } else { delete(key: .refreshToken) } }
    }

    func clearAll() {
        delete(key: .accessToken)
        delete(key: .refreshToken)
    }

    // MARK: - Private helpers

    @discardableResult
    private func save(_ value: String, key: Key) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Try updating existing item first
        let updateQuery: [CFString: Any] = [
            kSecClass:           kSecClassGenericPassword,
            kSecAttrAccount:     key.rawValue,
        ]
        let updateAttributes: [CFString: Any] = [kSecValueData: data]
        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Item doesn't exist — add it
            let addQuery: [CFString: Any] = [
                kSecClass:           kSecClassGenericPassword,
                kSecAttrAccount:     key.rawValue,
                kSecValueData:       data,
                kSecAttrAccessible:  kSecAttrAccessibleWhenUnlocked,
            ]
            return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
        }

        return updateStatus == errSecSuccess
    }

    private func load(key: Key) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key.rawValue,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }

    @discardableResult
    private func delete(key: Key) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
