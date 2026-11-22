//
//  Product.swift
//  ProductCatalog
//

import Foundation

/// Product rating metadata returned by the catalog service
public nonisolated struct ProductRating: Codable, Hashable, Sendable {
    public let rate: Double
    public let count: Int

    public init(rate: Double, count: Int) {
        self.rate = rate
        self.count = count
    }
}

/// Core domain entity representing a product in the catalogue
public nonisolated struct Product: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let price: Double
    public let description: String
    public let category: String
    public let image: String
    public let rating: ProductRating

    public init(
        id: Int,
        title: String,
        price: Double,
        description: String,
        category: String,
        image: String,
        rating: ProductRating
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.image = image
        self.rating = rating
    }

    /// Formatted price string for UI display (e.g. "$109.95")
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? String(format: "$%.2f", price)
    }

    /// Star rating formatted to 1 decimal place (e.g. "4.5 ★")
    public var formattedRating: String {
        String(format: "%.1f ★", rating.rate)
    }
}
