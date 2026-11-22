//
//  APIResponse.swift
//  ProductCatalog
//

import Foundation

/// Standard success envelope returned by the backend API: { "data": T }
public nonisolated struct APIResponse<T: Codable & Sendable>: Codable, Sendable {
    public let data: T

    public init(data: T) {
        self.data = data
    }
}

/// Structured error payload returned by the backend API: { "error": { "code": ..., "message": ... } }
public nonisolated struct APIErrorEnvelope: Codable, Sendable, LocalizedError {
    public nonisolated struct ErrorContent: Codable, Sendable {
        public let code: String
        public let message: String
        public let details: [ValidationErrorField]?

        public init(code: String, message: String, details: [ValidationErrorField]? = nil) {
            self.code = code
            self.message = message
            self.details = details
        }
    }

    public nonisolated struct ValidationErrorField: Codable, Sendable {
        public let field: String?
        public let message: String

        public init(field: String?, message: String) {
            self.field = field
            self.message = message
        }
    }

    public let error: ErrorContent

    public init(error: ErrorContent) {
        self.error = error
    }

    public var errorDescription: String? {
        error.message
    }
}
