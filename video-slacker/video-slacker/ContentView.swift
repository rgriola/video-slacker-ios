// ContentView.swift
// Root view — routes between logged-out and logged-in states.
//
// Week 1: stub shell. No real auth logic yet.
// Week 3: replace LoginPlaceholderView with real AuthService-wired login form.
//         Replace AppShellView tabs with real content views.

import SwiftUI

struct ContentView: View {

    // Simple local state for Week 1. Week 3 replaces with AuthService.isAuthenticated.
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            AppShellView(onLogout: { isLoggedIn = false })
        } else {
            LoginPlaceholderView(onLogin: { isLoggedIn = true })
        }
    }
}

// MARK: - AppShellView (stub)

struct AppShellView: View {
    let onLogout: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                Text("Channels")
                    .navigationTitle("Channels")
            }
            .tabItem {
                Label("Channels", systemImage: AppIcons.channelPublic)
            }

            NavigationStack {
                Text("Direct Messages")
                    .navigationTitle("Direct Messages")
            }
            .tabItem {
                Label("DMs", systemImage: AppIcons.directMessage)
            }

            NavigationStack {
                VStack(spacing: 16) {
                    Text("You are signed in.")
                        .foregroundStyle(.secondary)
                    Button("Sign out", role: .destructive) { onLogout() }
                }
                .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: AppIcons.personCircle)
            }
        }
        .tint(Color(hex: "6366F1")) // DesignTokens brand primary
    }
}

// MARK: - LoginPlaceholderView (stub)

struct LoginPlaceholderView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: AppIcons.message)
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "6366F1"))

            VStack(spacing: 4) {
                Text("Video Slacker")
                    .font(.title2.bold())
                Text("Messaging for media production teams")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // TODO Week 3: replace with real OAuth2 PKCE Safari flow
            Button {
                onLogin()
            } label: {
                Label("Sign in (stub)", systemImage: AppIcons.login)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "6366F1"))
            .padding(.horizontal, 32)

            Text("Authentication will open Safari (Week 3)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(32)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
