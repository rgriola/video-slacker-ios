// video_slackerApp.swift
// App entry point.
//
// Week 1: bare bones — loads ConfigLoader, wires auth invalidation notification.
// Week 3: add AuthService PKCE flow and onOpenURL handler.

import SwiftUI
import Combine

@main
struct VideoSlackerApp: App {

    @StateObject private var authObserver = AuthSessionObserver()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // TODO Week 3: handle OAuth callback URL
                // .onOpenURL { url in ... }
        }
    }
}

// MARK: - AuthSessionObserver
// Listens for 401 → authSessionInvalidated broadcast.
// Forces ContentView to re-evaluate auth state and show login screen.

@MainActor
final class AuthSessionObserver: ObservableObject {
    @Published var isSessionValid = false

    init() {
        // Check for existing tokens on startup
        isSessionValid = KeychainService.shared.accessToken != nil

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInvalidated),
            name: .authSessionInvalidated,
            object: nil
        )
    }

    @objc private func sessionInvalidated() {
        isSessionValid = false
    }
}
