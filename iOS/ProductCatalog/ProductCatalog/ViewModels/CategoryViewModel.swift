//
//  CategoryViewModel.swift
//  ProductCatalog
//

import Foundation
import Combine

@MainActor
public final class CategoryViewModel: ObservableObject {
    public let category: String
    @Published public var categoryView: CategoryView?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private let repository: ProductRepositoryProtocol

    public init(category: String, repository: ProductRepositoryProtocol) {
        self.category = category
        self.repository = repository
    }

    /// Loads the category view with top-rated products first, followed by remaining products
    public func loadCategory() async {
        isLoading = true
        errorMessage = nil

        do {
            let view = try await repository.fetchCategoryView(category: category, topRated: 5)
            self.categoryView = view
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isLoading = false
    }

    public var topRatedProducts: [Product] {
        categoryView?.topRated ?? []
    }

    public var additionalProducts: [Product] {
        categoryView?.additionalProducts ?? []
    }
}
