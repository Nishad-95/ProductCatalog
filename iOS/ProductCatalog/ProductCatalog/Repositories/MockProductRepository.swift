//
//  MockProductRepository.swift
//  ProductCatalog
//

import Foundation

/// Mock implementation of ProductRepositoryProtocol for SwiftUI previews and unit tests
public final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {
    public var shouldThrowError: Bool = false
    public var customProducts: [Product]?

    public static let sampleProducts: [Product] = [
        Product(
            id: 1,
            title: "Fjallraven - Foldsack No. 1 Backpack",
            price: 109.95,
            description: "Your perfect pack for everyday use and walks in the forest.",
            category: "men's clothing",
            image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
            rating: ProductRating(rate: 3.9, count: 120)
        ),
        Product(
            id: 2,
            title: "Mens Casual Premium Slim Fit T-Shirts",
            price: 22.30,
            description: "Slim-fitting style, contrast raglan long sleeve.",
            category: "men's clothing",
            image: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg",
            rating: ProductRating(rate: 4.1, count: 259)
        ),
        Product(
            id: 3,
            title: "John Hardy Women's Legends Naga Gold & Silver Dragon Station Chain Bracelet",
            price: 695.00,
            description: "From our Legends Collection, the Naga was inspired by the mythical water dragon.",
            category: "jewelery",
            image: "https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_.jpg",
            rating: ProductRating(rate: 4.6, count: 400)
        ),
        Product(
            id: 4,
            title: "WD 2TB Elements Portable External Hard Drive",
            price: 64.00,
            description: "USB 3.0 and USB 2.0 Compatibility Fast data transfers.",
            category: "electronics",
            image: "https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg",
            rating: ProductRating(rate: 3.3, count: 203)
        ),
        Product(
            id: 5,
            title: "BIYLACLESEN Women's 3-in-1 Snowboard Jacket",
            price: 56.99,
            description: "Material: 100% Polyester; Detachable Liner Fabric: Warm Fleece.",
            category: "women's clothing",
            image: "https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_.jpg",
            rating: ProductRating(rate: 2.6, count: 235)
        )
    ]

    public init(shouldThrowError: Bool = false) {
        self.shouldThrowError = shouldThrowError
    }

    public func fetchFeaturedProducts() async throws -> [Product] {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        return Array((customProducts ?? Self.sampleProducts).prefix(5))
    }

    public func fetchAllProducts() async throws -> [Product] {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        return customProducts ?? Self.sampleProducts
    }

    public func fetchProduct(id: Int) async throws -> Product {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        let all = customProducts ?? Self.sampleProducts
        guard let product = all.first(where: { $0.id == id }) else {
            throw APIError.serverError("Product \(id) not found")
        }
        return product
    }

    public func searchProducts(query: String) async throws -> [Product] {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return (customProducts ?? Self.sampleProducts).filter {
            $0.title.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    public func fetchCategories() async throws -> [String] {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        let all = customProducts ?? Self.sampleProducts
        return Array(Set(all.map { $0.category })).sorted()
    }

    public func fetchCategoryView(category: String, topRated: Int = 2) async throws -> CategoryView {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        let all = customProducts ?? Self.sampleProducts
        let matching = all.filter { $0.category.lowercased() == category.lowercased() }
        let sorted = matching.sorted { $0.rating.rate > $1.rating.rate }
        let top = Array(sorted.prefix(topRated))
        let topIds = Set(top.map { $0.id })
        let additional = matching.filter { !topIds.contains($0.id) }

        return CategoryView(
            category: category,
            topRated: top,
            additionalProducts: additional,
            totalCount: matching.count
        )
    }

    public func submitEnquiry(input: EnquiryInput) async throws -> EnquiryResult {
        if shouldThrowError { throw APIError.serverError("Mock error occurred") }
        return EnquiryResult(
            id: "mock_enq_\(UUID().uuidString.prefix(8))",
            success: true,
            message: "Thank you for your enquiry. Our sales team will get back to you shortly.",
            receivedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
