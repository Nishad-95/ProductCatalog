//
//  APIError.swift
//  ProductCatalog
//

import Foundation

/// Unified error representation for all network and API failures
public nonisolated enum APIError: LocalizedError, Sendable {
    case invalidURL(String)
    case networkFailure(String)
    case httpError(statusCode: Int, envelope: APIErrorEnvelope?)
    case decodingFailure(String)
    case serverError(String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL format: \(urlString)"
        case .networkFailure(let reason):
            return "Network connection failed: \(reason)"
        case .httpError(let statusCode, let envelope):
            if let message = envelope?.error.message {
                return message
            }
            return "Server returned HTTP status code \(statusCode)."
        case .decodingFailure(let reason):
            return "Failed to parse response data: \(reason)"
        case .serverError(let message):
            return message
        case .unknown:
            return "An unknown network error occurred."
        }
    }
}
