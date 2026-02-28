// PKCEGenerator.swift
// RFC 7636 PKCE implementation using CryptoKit.
// Generates a cryptographically random code_verifier and derives
// the code_challenge by base64url-encoding its SHA-256 hash.

import Foundation
import CryptoKit

struct PKCEGenerator {

    /// A random 32-byte (256-bit) code verifier, base64url-encoded.
    let codeVerifier: String

    /// SHA-256 hash of the code verifier, base64url-encoded (S256 method).
    let codeChallenge: String

    let codeChallengeMethod = "S256"

    init() {
        // 32 random bytes → 43-char base64url string (within 43-128 char spec)
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        self.codeVerifier = Data(bytes).base64URLEncodedString()

        // SHA-256(code_verifier) → base64url
        let digest = SHA256.hash(data: Data(self.codeVerifier.utf8))
        self.codeChallenge = Data(digest).base64URLEncodedString()
    }
}

// MARK: - Data base64url helper

private extension Data {
    /// Standard base64 with `+`→`-`, `/`→`_`, `=` padding stripped (per RFC 4648 §5)
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
