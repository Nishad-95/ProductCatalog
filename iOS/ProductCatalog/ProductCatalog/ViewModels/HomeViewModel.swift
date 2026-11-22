//
//  HomeViewModel.swift
//  ProductCatalog
//

import Foundation
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var selectedCategory: String = "All"
    @Published public var categories: [String] = ["All"]
    @Published public var featuredProducts: [Product] = []
    @Published public var remainingProducts: [Product] = []
    @Published public var searchQuery: String = ""
    @Published public var searchResults: [Product] = []
    @Published public var isLoading: Bool = false
    @Published public var isSearching: Bool = false
    @Published public var errorMessage: String? = nil

    private let repository: ProductRepositoryProtocol
    private var searchCancellable: AnyCancellable?

    public init(repository: ProductRepositoryProtocol) {
        self.repository = repository
        setupSearchDebounce()
    }

    /// Loads initial home screen data with "All" selected by default
    public func loadHomeData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let cats = repository.fetchCategories()
            async let view = repository.fetchCategoryView(category: selectedCategory, topRated: 5)

            let (loadedCategories, loadedView) = try await (cats, view)
            self.categories = ["All"] + loadedCategories.filter { $0.lowercased() != "all" }
            self.featuredProducts = loadedView.topRated
            self.remainingProducts = loadedView.additionalProducts
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isLoading = false
    }

    /// Selects a category and loads its 5 featured products followed by remaining products
    public func selectCategory(_ category: String) async {
        guard category != selectedCategory else { return }
        selectedCategory = category
        isLoading = true
        errorMessage = nil

        do {
            let view = try await repository.fetchCategoryView(category: category, topRated: 5)
            self.featuredProducts = view.topRated
            self.remainingProducts = view.additionalProducts
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isLoading = false
    }

    /// Sets up 350ms debounced live search across the complete product catalogue
    private func setupSearchDebounce() {
        searchCancellable = $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { [weak self] in
                    await self?.performSearch(query: query)
                }
            }
    }

    public func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.searchResults = []
            self.isSearching = false
            return
        }

        self.isSearching = true
        do {
            self.searchResults = try await repository.searchProducts(query: trimmed)
        } catch {
            self.searchResults = []
        }
        self.isSearching = false
    }

    public func clearSearch() {
        self.searchQuery = ""
        self.searchResults = []
        self.isSearching = false
    }
}
