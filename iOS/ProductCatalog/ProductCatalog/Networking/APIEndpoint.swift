//
//  APIEndpoint.swift
//  ProductCatalog
//

import Foundation

public nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

public nonisolated struct APIEndpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let body: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
    }

    // MARK: - Factory Endpoints

    /// Home Page: Top 5 featured products
    public static var featuredProducts: APIEndpoint {
        APIEndpoint(path: "/products/featured")
    }

    /// All products
    public static var allProducts: APIEndpoint {
        APIEndpoint(path: "/products")
    }

    /// Product Details by ID
    public static func product(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/products/\(id)")
    }

    /// Search products by query term
    public static func search(query: String) -> APIEndpoint {
        APIEndpoint(
            path: "/products/search",
            queryItems: [URLQueryItem(name: "q", value: query)]
        )
    }

    /// List all categories
    public static var categories: APIEndpoint {
        APIEndpoint(path: "/categories")
    }

    /// Category Page view (top-rated + additional products)
    public static func category(name: String, topRated: Int = 2) -> APIEndpoint {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        return APIEndpoint(
            path: "/categories/\(encodedName)",
            queryItems: [URLQueryItem(name: "topRated", value: "\(topRated)")]
        )
    }

    /// Submit customer enquiry
    public static func submitEnquiry(input: EnquiryInput) throws -> APIEndpoint {
        let encoder = JSONEncoder()
        let data = try encoder.encode(input)
        return APIEndpoint(
            path: "/enquiries",
            method: .post,
            body: data
        )
    }
}
