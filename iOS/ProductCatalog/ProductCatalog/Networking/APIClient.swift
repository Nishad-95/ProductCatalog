//
//  APIClient.swift
//  ProductCatalog
//

import Foundation

/// Protocol abstraction for making asynchronous HTTP requests
public protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}

/// Concrete URLSession-based API client conforming to Swift Concurrency
public final class APIClient: APIClientProtocol, Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        // Construct full URL
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw APIError.invalidURL("\(baseURL.absoluteString)\(endpoint.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Execute URLSession data task with async/await
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        // Check for HTTP error status codes
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorEnvelope = try? decoder.decode(APIErrorEnvelope.self, from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, envelope: errorEnvelope)
        }

        // Decode success payload
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailure("Failed to decode \(T.self): \(error.localizedDescription)")
        }
    }
}
