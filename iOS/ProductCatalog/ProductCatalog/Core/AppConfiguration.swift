//
//  AppConfiguration.swift
//  ProductCatalog
//

import Foundation

/// Centralized app runtime configuration
public nonisolated struct AppConfiguration: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /// Default configuration tailored for iOS Simulator local development
    public static var `default`: AppConfiguration {
        // Allow runtime override via scheme process environment
        if let envUrlString = ProcessInfo.processInfo.environment["PRODUCT_CATALOG_BASE_URL"],
           let envUrl = URL(string: envUrlString) {
            return AppConfiguration(baseURL: envUrl)
        }

        #if targetEnvironment(simulator)
        // 127.0.0.1 connects directly to the local host Mac machine from the iOS Simulator
        let defaultURL = URL(string: "http://127.0.0.1:3000/api/v1")!
        #else
        // Fallback for local physical device on Wi-Fi or staging
        let defaultURL = URL(string: "http://localhost:3000/api/v1")!
        #endif

        return AppConfiguration(baseURL: defaultURL)
    }
}
