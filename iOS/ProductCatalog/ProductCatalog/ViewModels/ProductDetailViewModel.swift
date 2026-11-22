//
//  ProductDetailViewModel.swift
//  ProductCatalog
//

import Foundation
import Combine

@MainActor
public final class ProductDetailViewModel: ObservableObject {
    public let productId: Int
    @Published public var product: Product?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isEnquiryPresented: Bool = false

    private let repository: ProductRepositoryProtocol

    public init(productId: Int, initialProduct: Product? = nil, repository: ProductRepositoryProtocol) {
        self.productId = productId
        self.product = initialProduct
        self.repository = repository
    }

    /// Fetches up-to-date product details from the backend
    public func loadProduct() async {
        if product != nil { return } // Already initialized with product data

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await repository.fetchProduct(id: productId)
            self.product = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isLoading = false
    }

    public func presentEnquiry() {
        self.isEnquiryPresented = true
    }
}
