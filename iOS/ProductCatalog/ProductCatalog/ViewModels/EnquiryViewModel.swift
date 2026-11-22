//
//  EnquiryViewModel.swift
//  ProductCatalog
//

import Foundation
import Combine

@MainActor
public final class EnquiryViewModel: ObservableObject {
    public let product: Product

    @Published public var name: String = ""
    @Published public var email: String = ""
    @Published public var phone: String = ""
    @Published public var message: String = ""

    @Published public var isSubmitting: Bool = false
    @Published public var submissionResult: EnquiryResult? = nil
    @Published public var errorMessage: String? = nil
    @Published public var validationMessage: String? = nil

    private let repository: ProductRepositoryProtocol

    public init(product: Product, repository: ProductRepositoryProtocol) {
        self.product = product
        self.repository = repository
        self.message = "Hi, I am interested in \"\(product.title)\" and would like more information."
    }

    public var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)

        let isEmailValid = trimmedEmail.contains("@") && trimmedEmail.contains(".") && trimmedEmail.count >= 5
        return trimmedName.count >= 2 && isEmailValid && trimmedMessage.count >= 5
    }

    /// Submits enquiry to backend API
    public func submitEnquiry() async {
        guard isFormValid else {
            validationMessage = "Please fill in your name, a valid email address, and a message."
            return
        }

        validationMessage = nil
        errorMessage = nil
        isSubmitting = true

        let input = EnquiryInput(
            productId: product.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone.trimmingCharacters(in: .whitespacesAndNewlines),
            message: message.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            let result = try await repository.submitEnquiry(input: input)
            self.submissionResult = result
        } catch {
            self.errorMessage = error.localizedDescription
        }

        self.isSubmitting = false
    }

    public func reset() {
        self.submissionResult = nil
        self.errorMessage = nil
        self.validationMessage = nil
    }
}
