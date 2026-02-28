// ConfigLoader.swift
// Reads Config.plist from the app bundle and exposes typed properties.
// Config.plist is gitignored — copy from Config.example.plist.

import Foundation

final class ConfigLoader {

    static let shared = ConfigLoader()

    // MARK: - Public properties

    let backendURL: URL
    let stagingURL: URL
    let oauthClientId: String
    let oauthRedirectUri: String
    let enableDebugLogging: Bool
    let enableFileAttachments: Bool

    // MARK: - Init

    private init() {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            fatalError("Config.plist not found. Copy Config.example.plist → Config.plist and fill in values.")
        }

        guard
            let backendString = dict["backendBaseURL"] as? String,
            let backendURL = URL(string: backendString),
            let stagingString = dict["backendStagingURL"] as? String,
            let stagingURL = URL(string: stagingString)
        else {
            fatalError("Config.plist: backendBaseURL / backendStagingURL missing or malformed.")
        }

        self.backendURL = backendURL
        self.stagingURL = stagingURL

        if let oauth = dict["oauth"] as? [String: Any] {
            self.oauthClientId   = oauth["clientId"]    as? String ?? "video-slacker-ios"
            self.oauthRedirectUri = oauth["redirectUri"] as? String ?? "videoslacker://oauth-callback"
        } else {
            self.oauthClientId    = "video-slacker-ios"
            self.oauthRedirectUri = "videoslacker://oauth-callback"
        }

        if let features = dict["features"] as? [String: Any] {
            self.enableDebugLogging    = features["enableDebugLogging"]    as? Bool ?? false
            self.enableFileAttachments = features["enableFileAttachments"] as? Bool ?? false
        } else {
            self.enableDebugLogging    = false
            self.enableFileAttachments = false
        }
    }
}
