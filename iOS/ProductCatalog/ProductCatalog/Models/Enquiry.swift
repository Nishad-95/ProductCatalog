//
//  Enquiry.swift
//  ProductCatalog
//

import Foundation

/// Request payload for submitting a customer enquiry
public nonisolated struct EnquiryInput: Codable, Sendable {
    public let productId: Int
    public let name: String
    public let email: String
    public let phone: String?
    public let message: String

    public init(
        productId: Int,
        name: String,
        email: String,
        phone: String? = nil,
        message: String
    ) {
        self.productId = productId
        self.name = name
        self.email = email
        self.phone = phone
        self.message = message
    }
}

/// Confirmation response received after submitting an enquiry
public nonisolated struct EnquiryResult: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let success: Bool
    public let message: String
    public let receivedAt: String

    public init(id: String, success: Bool, message: String, receivedAt: String) {
        self.id = id
        self.success = success
        self.message = message
        self.receivedAt = receivedAt
    }
}
