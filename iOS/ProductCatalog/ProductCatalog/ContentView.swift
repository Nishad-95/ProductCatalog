//
//  ContentView.swift
//  ProductCatalog
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        NavigationStack {
            HomeView(repository: container.repository)
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product, repository: container.repository)
                }
                .navigationDestination(for: String.self) { category in
                    CategoryListingView(category: category, repository: container.repository)
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.mock)
}
