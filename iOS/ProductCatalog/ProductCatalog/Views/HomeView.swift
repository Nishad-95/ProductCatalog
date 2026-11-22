//
//  HomeView.swift
//  ProductCatalog
//

import SwiftUI

/// Main Home Screen for the Catlog application
struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Search Bar Header
                searchBarSection

                if !viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // Live Search Results
                    searchResultsSection
                } else {
                    // Dynamic Category Chips (Default: "All")
                    categoryChipsSection

                    if viewModel.isLoading && viewModel.featuredProducts.isEmpty {
                        loadingSection
                    } else if let error = viewModel.errorMessage, viewModel.featuredProducts.isEmpty {
                        errorSection(error)
                    } else {
                        // Section 1: First 5 Products are ALWAYS Featured Products
                        featuredSection

                        // Section 2: Followed by the rest of the products
                        if !viewModel.remainingProducts.isEmpty {
                            remainingProductsSection
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Catlog")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.loadHomeData()
        }
        .task {
            if viewModel.featuredProducts.isEmpty {
                await viewModel.loadHomeData()
            }
        }
    }

    // MARK: - Subviews

    private var searchBarSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search in Catlog...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 4)
    }

    private var categoryChipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryChipView(
                            title: category,
                            isSelected: viewModel.selectedCategory.lowercased() == category.lowercased()
                        ) {
                            Task {
                                await viewModel.selectCategory(category)
                            }
                        }
                    }
                }
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.orange)
                        Text(viewModel.selectedCategory.lowercased() == "all" ? "Featured Products" : "Featured in \(viewModel.selectedCategory.capitalized)")
                            .font(.title3.weight(.bold))
                    }
                    Text("Top 5 products")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.featuredProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var remainingProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.selectedCategory.lowercased() == "all" ? "All Products" : "More in \(viewModel.selectedCategory.capitalized)")
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)
                .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.remainingProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Search Results")
                    .font(.title3.weight(.bold))
                Spacer()
                if viewModel.isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("\(viewModel.searchResults.count) found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .padding(.top, 30)

                    Text("No products found")
                        .font(.headline)

                    Text("We couldn't find any products matching \"\(viewModel.searchQuery)\".")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.searchResults) { product in
                        NavigationLink(value: product) {
                            ProductCardView(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading products...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Unable to Load Products")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadHomeData()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
