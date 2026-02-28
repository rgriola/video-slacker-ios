// APIClient.swift
// Central HTTP client for all API calls.
// - Automatically attaches Bearer token from KeychainService
// - On 401 response: clears tokens + broadcasts `authSessionInvalidated`
// - All methods are async/await and throw APIError on failure

import Foundation

// MARK: - Error type

enum APIError: LocalizedError {
    case invalidURL
    case encodingFailed
    case httpError(statusCode: Int, body: String)
    case decodingFailed(Error)
    case networkError(Error)
    case unauthorized          // triggers auto-logout

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Invalid URL."
        case .encodingFailed:      return "Failed to encode request body."
        case .httpError(let code, let body): return "HTTP \(code): \(body)"
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .networkError(let e): return e.localizedDescription
        case .unauthorized:        return "Session expired. Please sign in again."
        }
    }
}

// MARK: - Empty response sentinel

struct EmptyResponse: Decodable {}

// MARK: - APIClient

@MainActor
final class APIClient {

    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let config  = ConfigLoader.shared
    private let keychain = KeychainService.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy  = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy  = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Public methods

    func get<T: Decodable>(
        _ path: String,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "GET", body: nil as EmptyResponse?, authenticated: authenticated)
        return try await perform(request)
    }

    func post<Body: Encodable, T: Decodable>(
        _ path: String,
        body: Body,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST", body: body, authenticated: authenticated)
        return try await perform(request)
    }

    func patch<Body: Encodable, T: Decodable>(
        _ path: String,
        body: Body,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "PATCH", body: body, authenticated: authenticated)
        return try await perform(request)
    }

    func put<Body: Encodable, T: Decodable>(
        _ path: String,
        body: Body,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "PUT", body: body, authenticated: authenticated)
        return try await perform(request)
    }

    func delete<T: Decodable>(
        _ path: String,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "DELETE", body: nil as EmptyResponse?, authenticated: authenticated)
        return try await perform(request)
    }

    // MARK: - Private helpers

    private func buildRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body?,
        authenticated: Bool
    ) throws -> URLRequest {
        let base = config.backendURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let urlString = "\(base)\(path)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if authenticated, let token = keychain.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body, method != "GET" {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingFailed
            }
        }

        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        #if DEBUG
        if ConfigLoader.shared.enableDebugLogging {
            print("[APIClient] \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
        }
        #endif

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        #if DEBUG
        if ConfigLoader.shared.enableDebugLogging {
            print("[APIClient] ← \(http.statusCode)")
        }
        #endif

        if http.statusCode == 401 {
            handleUnauthorized()
            throw APIError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw APIError.httpError(statusCode: http.statusCode, body: body)
        }

        // Handle empty responses
        if T.self == EmptyResponse.self, let empty = EmptyResponse() as? T {
            return empty
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private func handleUnauthorized() {
        keychain.clearAll()
        NotificationCenter.default.post(name: .authSessionInvalidated, object: nil)
    }
}

// MARK: - Notification name

extension Notification.Name {
    static let authSessionInvalidated = Notification.Name("authSessionInvalidated")
}
