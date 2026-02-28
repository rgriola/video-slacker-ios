// ContentView.swift
// Root view — routes between logged-out and logged-in states.
//
// Week 1: stub shell. No real auth logic yet.
// Week 3: replace LoginPlaceholderView with real AuthService-wired login form.
//         Replace AppShellView tabs with real content views.

import SwiftUI

struct ContentView: View {

    @StateObject private var authService = AuthService.shared

    var body: some View {
        Group {
            if authService.isAuthenticated {
                AppShellView(onLogout: {
                    Task { await authService.logout() }
                })
            } else {
                LoginPlaceholderView()
            }
        }
        .overlay {
            if authService.isLoading {
                ProgressView()
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .alert("Sign-in Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") { authService.errorMessage = nil }
        } message: {
            Text(authService.errorMessage ?? "")
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

// MARK: - LoginPlaceholderView

struct LoginPlaceholderView: View {

    @StateObject private var authService = AuthService.shared

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

            Button {
                authService.startLogin()
            } label: {
                Label("Sign in", systemImage: AppIcons.login)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "6366F1"))
            .padding(.horizontal, 32)
            .disabled(authService.isLoading)

            Text("Opens Safari for secure sign-in")
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
