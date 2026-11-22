//
//  ProductCatalogApp.swift
//  ProductCatalog
//

import SwiftUI

@main
struct ProductCatalogApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }
}
