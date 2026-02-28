// KeychainService.swift
// Stores and retrieves access + refresh tokens from the iOS Keychain.
// Uses KeychainAccess (kishikawakatsumi/KeychainAccess 4.2.2) via SPM.

import Foundation
import KeychainAccess

final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    // MARK: - Private keychain instance

    private let keychain = Keychain(service: "com.videoslacker")
        .accessibility(.whenUnlocked)
        .synchronizable(false)

    // MARK: - Keys

    private enum Key: String {
        case accessToken  = "accessToken"
        case refreshToken = "refreshToken"
    }

    // MARK: - Public API

    var accessToken: String? {
        get { keychain[Key.accessToken.rawValue] }
        set { keychain[Key.accessToken.rawValue] = newValue }
    }

    var refreshToken: String? {
        get { keychain[Key.refreshToken.rawValue] }
        set { keychain[Key.refreshToken.rawValue] = newValue }
    }

    func clearAll() {
        try? keychain.removeAll()
    }
}
