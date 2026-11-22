//
//  ContentView.swift
//  ProductCatalog
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var isSplashActive: Bool = true

    var body: some View {
        ZStack {
            // Main Catalogue Navigation
            NavigationStack {
                HomeView(repository: container.repository)
                    .navigationDestination(for: Product.self) { product in
                        ProductDetailView(product: product, repository: container.repository)
                    }
                    .navigationDestination(for: String.self) { category in
                        CategoryListingView(category: category, repository: container.repository)
                    }
            }

            // Animated Splash Screen
            if isSplashActive {
                SplashScreenView(onFinished: {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        isSplashActive = false
                    }
                })
                .transition(.asymmetric(
                    insertion: .identity,
                    removal: .opacity.combined(with: .scale(scale: 1.06))
                ))
                .zIndex(1)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.mock)
}
