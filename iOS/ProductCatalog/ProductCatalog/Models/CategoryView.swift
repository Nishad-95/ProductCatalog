//
//  CategoryView.swift
//  ProductCatalog
//

import Foundation

/// Composite response model for the Category Page user journey
public nonisolated struct CategoryView: Codable, Hashable, Sendable {
    public let category: String
    public let topRated: [Product]
    public let additionalProducts: [Product]
    public let totalCount: Int

    public init(
        category: String,
        topRated: [Product],
        additionalProducts: [Product],
        totalCount: Int
    ) {
        self.category = category
        self.topRated = topRated
        self.additionalProducts = additionalProducts
        self.totalCount = totalCount
    }
}
