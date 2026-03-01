// AuthService.swift
// OAuth2 + PKCE authentication flow via Safari.
// - startLogin()          → opens Safari with PKCE challenge
// - handleCallback(url:)  → exchanges auth code for tokens, saves to Keychain
// - refreshTokenIfNeeded() → silently rotates tokens before expiry
// - logout()              → revokes refresh token, clears Keychain
//
// Listens for .authSessionInvalidated notification from APIClient
// (fired on any 401 response) to auto-logout stale sessions.

import Foundation
import Combine
import AuthenticationServices

@MainActor
final class AuthService: NSObject, ObservableObject {

    static let shared = AuthService()

    // MARK: - Published state

    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private

    private let keychain = KeychainService.shared
    private let config   = ConfigLoader.shared
    private var pkce: PKCEGenerator?
    private var webAuthSession: ASWebAuthenticationSession?

    // MARK: - Init

    private override init() {
        super.init()
        // Restore session from Keychain on launch
        if keychain.accessToken != nil {
            isAuthenticated = true
        }
        // Listen for 401 auto-logout signal from APIClient
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionInvalidated),
            name: .authSessionInvalidated,
            object: nil
        )
    }

    // MARK: - Login

    /// Opens Safari with OAuth2 authorization URL + PKCE challenge.
    func startLogin() {
        guard let authURL = buildAuthorizationURL() else {
            errorMessage = "Could not build sign-in URL."
            return
        }

        let callbackScheme = config.oauthRedirectScheme  // "videoslacker"

        webAuthSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self.errorMessage = "Sign-in was cancelled."
                    }
                    return
                }
                guard let url = callbackURL else { return }
                await self.handleCallback(url: url)
            }
        }

        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        webAuthSession?.start()
    }

    // MARK: - Callback handling

    /// Exchanges the authorization code for access + refresh tokens.
    func handleCallback(url: URL) async {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
            let verifier = pkce?.codeVerifier
        else {
            errorMessage = "Invalid authorization response."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let body = TokenExchangeRequest(
                grantType: "authorization_code",
                code: code,
                codeVerifier: verifier,
                clientId: config.oauthClientId,
                redirectUri: config.oauthRedirectUri
            )

            let response: TokenResponse = try await APIClient.shared.post(
                "/api/auth/oauth/token",
                body: body,
                authenticated: false
            )

            keychain.accessToken  = response.accessToken
            keychain.refreshToken = response.refreshToken
            isAuthenticated       = true
            pkce = nil

        } catch {
            errorMessage = "Sign-in failed. Please try again."
            #if DEBUG
            if config.enableDebugLogging {
                print("[AuthService] Token exchange failed: \(error)")
            }
            #endif
        }
    }

    // MARK: - Token refresh

    /// Silently refreshes the access token using the stored refresh token.
    /// Called automatically by APIClient before any authenticated request if needed.
    @discardableResult
    func refreshTokenIfNeeded() async -> Bool {
        guard let refreshToken = keychain.refreshToken else {
            await logout()
            return false
        }

        do {
            let body = TokenRefreshRequest(
                grantType: "refresh_token",
                refreshToken: refreshToken,
                clientId: config.oauthClientId
            )

            let response: TokenResponse = try await APIClient.shared.post(
                "/api/auth/oauth/token",
                body: body,
                authenticated: false
            )

            keychain.accessToken  = response.accessToken
            keychain.refreshToken = response.refreshToken
            return true

        } catch {
            #if DEBUG
            if config.enableDebugLogging {
                print("[AuthService] Token refresh failed: \(error)")
            }
            #endif
            await logout()
            return false
        }
    }

    // MARK: - Logout

    func logout() async {
        if let refreshToken = keychain.refreshToken {
            // Best-effort revoke — don't wait or error if it fails
            let body = TokenRevokeRequest(
                token: refreshToken,
                clientId: config.oauthClientId
            )
            _ = try? await APIClient.shared.post(
                "/api/auth/oauth/revoke",
                body: body,
                authenticated: false
            ) as EmptyResponse
        }

        keychain.clearAll()
        isAuthenticated = false
    }

    // MARK: - 401 auto-logout

    @objc private func handleSessionInvalidated() {
        Task { @MainActor in
            keychain.clearAll()
            isAuthenticated = false
        }
    }

    // MARK: - Helpers

    private func buildAuthorizationURL() -> URL? {
        let fresh = PKCEGenerator()
        pkce = fresh

        var components = URLComponents(
            url: config.backendURL.appendingPathComponent("/api/auth/oauth/authorize"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "response_type",           value: "code"),
            URLQueryItem(name: "client_id",               value: config.oauthClientId),
            URLQueryItem(name: "redirect_uri",            value: config.oauthRedirectUri),
            URLQueryItem(name: "scope",                   value: config.oauthScopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge",          value: fresh.codeChallenge),
            URLQueryItem(name: "code_challenge_method",   value: fresh.codeChallengeMethod),
        ]
        return components?.url
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension AuthService: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }.first
            return UIWindow(windowScene: scene!)
        }
    }
}

// MARK: - Request / Response models

private struct TokenExchangeRequest: Encodable {
    let grantType: String
    let code: String
    let codeVerifier: String
    let clientId: String
    let redirectUri: String
}

private struct TokenRefreshRequest: Encodable {
    let grantType: String
    let refreshToken: String
    let clientId: String
}

private struct TokenRevokeRequest: Encodable {
    let token: String
    let clientId: String
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String?
    let expiresIn: Int?
}
