//
//  AppContainer.swift
//  ProductCatalog
//

import Foundation
import Combine

/// Dependency Injection container providing application-wide services
@MainActor
public final class AppContainer: ObservableObject {
    public let configuration: AppConfiguration
    public let apiClient: APIClientProtocol
    public let repository: ProductRepositoryProtocol

    public init(
        configuration: AppConfiguration = .default,
        apiClient: APIClientProtocol? = nil,
        repository: ProductRepositoryProtocol? = nil
    ) {
        self.configuration = configuration
        let resolvedClient = apiClient ?? APIClient(baseURL: configuration.baseURL)
        self.apiClient = resolvedClient
        self.repository = repository ?? ProductRepository(apiClient: resolvedClient)
    }

    /// Pre-configured mock container for SwiftUI previews and offline unit tests
    public static var mock: AppContainer {
        let mockRepo = MockProductRepository()
        let dummyClient = APIClient(baseURL: URL(string: "http://mock.local")!)
        return AppContainer(
            configuration: AppConfiguration(baseURL: URL(string: "http://mock.local")!),
            apiClient: dummyClient,
            repository: mockRepo
        )
    }
}
