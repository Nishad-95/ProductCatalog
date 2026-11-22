//
//  ProductCatalogTests.swift
//  ProductCatalogTests
//

import Testing
import Foundation
@testable import ProductCatalog

struct ProductCatalogTests {

    @Test func testProductDecoding() throws {
        let json = """
        {
            "data": {
                "id": 1,
                "title": "Fjallraven Backpack",
                "price": 109.95,
                "description": "Durable backpack",
                "category": "men's clothing",
                "image": "https://example.com/1.jpg",
                "rating": {
                    "rate": 3.9,
                    "count": 120
                }
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(APIResponse<Product>.self, from: json)
        #expect(response.data.id == 1)
        #expect(response.data.title == "Fjallraven Backpack")
        #expect(response.data.price == 109.95)
        #expect(response.data.rating.rate == 3.9)
        #expect(response.data.rating.count == 120)
        #expect(response.data.formattedPrice == "$109.95")
        #expect(response.data.formattedRating == "3.9 ★")
    }

    @Test func testCategoryViewDecoding() throws {
        let json = """
        {
            "data": {
                "category": "electronics",
                "topRated": [
                    {
                        "id": 3,
                        "title": "Smart Watch",
                        "price": 199.99,
                        "description": "Water resistant",
                        "category": "electronics",
                        "image": "https://example.com/3.jpg",
                        "rating": { "rate": 4.9, "count": 200 }
                    }
                ],
                "additionalProducts": [],
                "totalCount": 1
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(APIResponse<CategoryView>.self, from: json)
        #expect(response.data.category == "electronics")
        #expect(response.data.topRated.count == 1)
        #expect(response.data.totalCount == 1)
    }

    @Test func testEnquiryInputEncodingAndResultDecoding() throws {
        let input = EnquiryInput(
            productId: 1,
            name: "Jane Doe",
            email: "jane@example.com",
            phone: "1234567890",
            message: "I am interested in this product."
        )

        let encodedData = try JSONEncoder().encode(input)
        #expect(!encodedData.isEmpty)

        let resultJson = """
        {
            "data": {
                "id": "enq_12345",
                "success": true,
                "message": "Thank you for your enquiry.",
                "receivedAt": "2026-11-22T10:00:00.000Z"
            }
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(APIResponse<EnquiryResult>.self, from: resultJson)
        #expect(result.data.success == true)
        #expect(result.data.id == "enq_12345")
        #expect(result.data.message == "Thank you for your enquiry.")
    }

    @Test func testAPIErrorEnvelopeDecoding() throws {
        let errorJson = """
        {
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Invalid request data",
                "details": [
                    { "field": "email", "message": "Invalid email address" }
                ]
            }
        }
        """.data(using: .utf8)!

        let envelope = try JSONDecoder().decode(APIErrorEnvelope.self, from: errorJson)
        #expect(envelope.error.code == "VALIDATION_ERROR")
        #expect(envelope.error.message == "Invalid request data")
        #expect(envelope.error.details?.count == 1)
        #expect(envelope.errorDescription == "Invalid request data")
    }

    @Test func testMockProductRepositoryOperations() async throws {
        let repository = MockProductRepository()

        // Test featured products (top 5)
        let featured = try await repository.fetchFeaturedProducts()
        #expect(featured.count == 5)

        // Test search
        let searchResults = try await repository.searchProducts(query: "backpack")
        #expect(searchResults.count == 1)
        #expect(searchResults.first?.id == 1)

        // Test category view
        let categoryView = try await repository.fetchCategoryView(category: "men's clothing", topRated: 1)
        #expect(categoryView.category == "men's clothing")
        #expect(categoryView.topRated.count == 1)
        #expect(categoryView.additionalProducts.count == 1)

        // Test enquiry submission
        let input = EnquiryInput(productId: 1, name: "Test User", email: "test@example.com", message: "Hello")
        let enquiryResult = try await repository.submitEnquiry(input: input)
        #expect(enquiryResult.success == true)
        #expect(enquiryResult.id.hasPrefix("mock_enq_"))
    }

    @Test func testAppConfigurationDefault() {
        let config = AppConfiguration.default
        #expect(config.baseURL.absoluteString.contains("/api/v1"))
    }
}
