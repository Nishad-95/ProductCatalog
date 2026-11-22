//
//  EnquirySheetView.swift
//  ProductCatalog
//

import SwiftUI

/// Modal sheet allowing customers to submit product enquiries to the sales team
struct EnquirySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EnquiryViewModel

    init(product: Product, repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: EnquiryViewModel(product: product, repository: repository))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let result = viewModel.submissionResult {
                    // Confirmation Thank You Screen
                    thankYouView(result: result)
                } else {
                    // Enquiry Form
                    formView
                }
            }
            .navigationTitle("Product Enquiry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(viewModel.submissionResult == nil ? "Cancel" : "Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Form View

    private var formView: some View {
        Form {
            // Product summary header
            Section {
                HStack(spacing: 12) {
                    AsyncProductImage(urlString: viewModel.product.image, contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.product.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(2)
                        Text(viewModel.product.formattedPrice)
                            .font(.caption.weight(.bold))
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Product")
            }

            // Customer Contact Details
            Section {
                TextField("Your Full Name *", text: $viewModel.name)
                    .textContentType(.name)
                    .autocorrectionDisabled()

                TextField("Email Address *", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Phone Number (Optional)", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            } header: {
                Text("Contact Details")
            } footer: {
                Text("Our sales team will contact you at this email address.")
            }

            // Message Body
            Section {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 100)
            } header: {
                Text("Message *")
            }

            // Error feedback
            if let error = viewModel.errorMessage ?? viewModel.validationMessage {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            // Submit Button
            Section {
                Button(action: {
                    Task {
                        await viewModel.submitEnquiry()
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 6)
                        }
                        Text(viewModel.isSubmitting ? "Submitting..." : "Send Enquiry")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .disabled(viewModel.isSubmitting || !viewModel.isFormValid)
            }
        }
    }

    // MARK: - Thank You Confirmation View

    private func thankYouView(result: EnquiryResult) -> some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }

            VStack(spacing: 8) {
                Text("Thank You!")
                    .font(.title2.weight(.bold))

                Text(result.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 4) {
                Text("Reference ID: \(result.id)")
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)

                Text("Product: \(viewModel.product.title)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, 8)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .padding()
    }
}
