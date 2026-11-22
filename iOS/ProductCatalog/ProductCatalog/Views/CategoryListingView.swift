//
//  CategoryListingView.swift
//  ProductCatalog
//

import SwiftUI

/// Category listing screen displaying top-rated products first, followed by additional products
struct CategoryListingView: View {
    @StateObject private var viewModel: CategoryViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(category: String, repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(category: category, repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.isLoading && viewModel.categoryView == nil {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.categoryView == nil {
                    errorView(error)
                } else {
                    // Section 1: Top Rated in Category
                    if !viewModel.topRatedProducts.isEmpty {
                        topRatedSection
                    }

                    // Section 2: Remaining Category Products
                    if !viewModel.additionalProducts.isEmpty {
                        additionalProductsSection
                    } else if viewModel.topRatedProducts.isEmpty {
                        emptyView
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle(viewModel.category.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadCategory()
        }
        .task {
            if viewModel.categoryView == nil {
                await viewModel.loadCategory()
            }
        }
    }

    // MARK: - Subviews

    private var topRatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.orange)
                Text("Featured in \(viewModel.category.capitalized)")
                    .font(.headline)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.topRatedProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var additionalProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All \(viewModel.category.capitalized) Products")
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.additionalProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading \(viewModel.category.capitalized)...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No products in this category")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Failed to Load Category")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await viewModel.loadCategory()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
