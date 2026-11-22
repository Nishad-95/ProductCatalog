//
//  ProductRepository.swift
//  ProductCatalog
//

import Foundation

/// Production implementation of ProductRepositoryProtocol using APIClient
public final class ProductRepository: ProductRepositoryProtocol, Sendable {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchFeaturedProducts() async throws -> [Product] {
        let response: APIResponse<[Product]> = try await apiClient.request(.featuredProducts)
        return response.data
    }

    public func fetchAllProducts() async throws -> [Product] {
        let response: APIResponse<[Product]> = try await apiClient.request(.allProducts)
        return response.data
    }

    public func fetchProduct(id: Int) async throws -> Product {
        let response: APIResponse<Product> = try await apiClient.request(.product(id: id))
        return response.data
    }

    public func searchProducts(query: String) async throws -> [Product] {
        let response: APIResponse<[Product]> = try await apiClient.request(.search(query: query))
        return response.data
    }

    public func fetchCategories() async throws -> [String] {
        let response: APIResponse<[String]> = try await apiClient.request(.categories)
        return response.data
    }

    public func fetchCategoryView(category: String, topRated: Int = 2) async throws -> CategoryView {
        let response: APIResponse<CategoryView> = try await apiClient.request(
            .category(name: category, topRated: topRated)
        )
        return response.data
    }

    public func submitEnquiry(input: EnquiryInput) async throws -> EnquiryResult {
        let endpoint = try APIEndpoint.submitEnquiry(input: input)
        let response: APIResponse<EnquiryResult> = try await apiClient.request(endpoint)
        return response.data
    }
}
