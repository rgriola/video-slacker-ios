// SSEService.swift
// Maintains a persistent Server-Sent Events connection to GET /api/v1/sse.
//
// Architecture:
//   • Single shared instance (@MainActor)
//   • Streams raw bytes via URLSession.bytes(for:) (iOS 15+)
//   • Reconnects automatically with exponential backoff (1 s → 30 s cap)
//   • Dispatches typed SSEEvent values via NotificationCenter
//
// Starting / stopping:
//   • Call connect() after successful login (AuthService broadcasts .authStateChanged)
//   • Call disconnect() on logout
//   • The service self-connects on token refresh success via the same notification
//
// Receiving events:
//   • Subscribe to Notification.Name.sseEvent (or the specific named constants)
//   • The userInfo["sseEvent"] key holds the SSEEvent value
//
// Example:
//   NotificationCenter.default.addObserver(
//     forName: .sseMessageCreated, object: nil, queue: .main
//   ) { notification in
//     guard let event = notification.userInfo?["sseEvent"] as? SSEEvent else { return }
//     // react to event.payload
//   }

import Foundation
import Combine

// MARK: - Event model

struct SSEEvent {
    let type: String
    let workspaceId: String?
    let channelId: String?
    /// Raw JSON payload dictionary for the event
    let payload: [String: Any]
}

// MARK: - Notification names

extension Notification.Name {
    /// Fired for every incoming SSE event. userInfo["sseEvent"] → SSEEvent
    static let sseEvent = Notification.Name("SSEService.event")

    // Convenience names for specific event types
    static let sseMessageCreated   = Notification.Name("SSEService.message.created")
    static let sseMessageUpdated   = Notification.Name("SSEService.message.updated")
    static let sseMessageDeleted   = Notification.Name("SSEService.message.deleted")
    static let sseReactionAdded    = Notification.Name("SSEService.reaction.added")
    static let sseReactionRemoved  = Notification.Name("SSEService.reaction.removed")
    static let sseTypingStart      = Notification.Name("SSEService.typing.start")
    static let sseTypingStop       = Notification.Name("SSEService.typing.stop")
    static let sseMemberJoined     = Notification.Name("SSEService.member.joined")
    static let sseMemberLeft       = Notification.Name("SSEService.member.left")
    static let ssePresenceUpdated  = Notification.Name("SSEService.presence.updated")

    /// Fired when the connection is established (or re-established)
    static let sseConnected    = Notification.Name("SSEService.connected")
    /// Fired when the connection drops and a retry is scheduled
    static let sseDisconnected = Notification.Name("SSEService.disconnected")
}

// MARK: - SSEService

@MainActor
final class SSEService: ObservableObject {

    static let shared = SSEService()

    // MARK: Published state

    @Published private(set) var isConnected = false

    // MARK: Private

    private let config   = ConfigLoader.shared
    private let keychain = KeychainService.shared

    private var streamTask: Task<Void, Never>?
    private var retryCount = 0
    private var cancellables = Set<AnyCancellable>()

    private let backoffBaseSeconds: Double = 1
    private let backoffMaxSeconds:  Double = 30

    // MARK: - Lifecycle

    private init() {
        // Observe AuthService.isAuthenticated via Combine.
        // connect() / disconnect() are called automatically as auth state changes.
        AuthService.shared.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                guard let self else { return }
                Task { @MainActor in
                    if isAuthenticated {
                        self.connect()
                    } else {
                        self.disconnect()
                    }
                }
            }
            .store(in: &cancellables)

        // Also listen for 401 auto-logout signal from APIClient
        NotificationCenter.default.addObserver(
            forName: .authSessionInvalidated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.disconnect() }
        }
    }

    // MARK: - Public API

    /// Open (or re-open) the SSE connection.
    func connect() {
        guard streamTask == nil else { return } // already running
        guard keychain.accessToken != nil else {
            #if DEBUG
            if config.enableDebugLogging { print("[SSEService] No access token — skipping connect") }
            #endif
            return
        }

        retryCount = 0
        streamTask = Task {
            await streamLoop()
        }
    }

    /// Close the SSE connection and stop all retries.
    func disconnect() {
        streamTask?.cancel()
        streamTask = nil
        retryCount = 0
        isConnected = false
        NotificationCenter.default.post(name: .sseDisconnected, object: nil)
    }

    // MARK: - Stream loop

    /// Runs until the task is cancelled. Reconnects with backoff on error.
    private func streamLoop() async {
        while !Task.isCancelled {
            do {
                try await openStream()
                // openStream() returned normally — server closed the connection.
                // Treat as a disconnect and retry.
            } catch is CancellationError {
                break
            } catch {
                #if DEBUG
                if config.enableDebugLogging { print("[SSEService] Stream error: \(error)") }
                #endif
            }

            guard !Task.isCancelled else { break }

            await MainActor.run {
                isConnected = false
                NotificationCenter.default.post(name: .sseDisconnected, object: nil)
            }

            let delay = min(backoffBaseSeconds * pow(2.0, Double(retryCount)), backoffMaxSeconds)
            retryCount += 1

            #if DEBUG
            if config.enableDebugLogging {
                print("[SSEService] Reconnecting in \(Int(delay))s (attempt \(retryCount))")
            }
            #endif

            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }

    // MARK: - Core stream reader

    private func openStream() async throws {
        guard let token = keychain.accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = config.backendURL.appendingPathComponent("/api/v1/sse")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = .infinity // SSE stream must not time out

        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }

        await MainActor.run {
            isConnected = true
            retryCount = 0
            NotificationCenter.default.post(name: .sseConnected, object: nil)
            #if DEBUG
            if config.enableDebugLogging { print("[SSEService] Connected") }
            #endif
        }

        // SSE parsing state machine
        var eventType: String?
        var dataLines: [String] = []

        for try await line in asyncBytes.lines {
            guard !Task.isCancelled else { break }

            if line.isEmpty {
                // Blank line → dispatch the accumulated event
                if let data = dataLines.first(where: { !$0.isEmpty }) {
                    let type = eventType ?? "message"
                    await parseAndDispatch(type: type, rawData: data)
                }
                eventType = nil
                dataLines.removeAll()
                continue
            }

            if line.hasPrefix(":") {
                // Comment / heartbeat — ignore
                continue
            }

            if line.hasPrefix("event:") {
                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                continue
            }

            if line.hasPrefix("data:") {
                let value = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                dataLines.append(value)
                continue
            }
        }
    }

    // MARK: - Event dispatch

    private func parseAndDispatch(type: String, rawData: String) async {
        guard let jsonData = rawData.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            #if DEBUG
            if config.enableDebugLogging { print("[SSEService] Failed to parse event JSON for type \(type)") }
            #endif
            return
        }

        // The server embeds `type` inside the JSON payload as well as in the
        // SSE `event:` field. Use the JSON type if present (more authoritative).
        let resolvedType   = json["type"]        as? String ?? type
        let workspaceId    = json["workspaceId"] as? String
        let channelId      = json["channelId"]   as? String
        let payload        = json["payload"]     as? [String: Any] ?? [:]

        let event = SSEEvent(
            type: resolvedType,
            workspaceId: workspaceId,
            channelId: channelId,
            payload: payload
        )

        let userInfo: [AnyHashable: Any] = ["sseEvent": event]

        // Generic notification
        NotificationCenter.default.post(name: .sseEvent, object: nil, userInfo: userInfo)

        // Named notification for this event type
        let specificName = Notification.Name("SSEService.\(resolvedType)")
        NotificationCenter.default.post(name: specificName, object: nil, userInfo: userInfo)

        #if DEBUG
        if config.enableDebugLogging {
            print("[SSEService] ↙︎ \(resolvedType) ws=\(workspaceId ?? "–") ch=\(channelId ?? "–")")
        }
        #endif
    }
}
