//
//  ProductRepositoryProtocol.swift
//  ProductCatalog
//

import Foundation

/// Repository contract decoupling UI/ViewModels from network implementation
public protocol ProductRepositoryProtocol: Sendable {
    /// Acceptance Criteria: Home page 5 featured products
    func fetchFeaturedProducts() async throws -> [Product]

    /// Fetch full catalogue of products
    func fetchAllProducts() async throws -> [Product]

    /// Acceptance Criteria: Product detail page by ID
    func fetchProduct(id: Int) async throws -> Product

    /// Acceptance Criteria: Search products matching text query
    func searchProducts(query: String) async throws -> [Product]

    /// List all categories
    func fetchCategories() async throws -> [String]

    /// Acceptance Criteria: Category page view (top-rated + additional products)
    func fetchCategoryView(category: String, topRated: Int) async throws -> CategoryView

    /// Acceptance Criteria: Submit customer enquiry
    func submitEnquiry(input: EnquiryInput) async throws -> EnquiryResult
}

public extension ProductRepositoryProtocol {
    func fetchCategoryView(category: String) async throws -> CategoryView {
        try await fetchCategoryView(category: category, topRated: 2)
    }
}
