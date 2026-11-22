//
//  ProductDetailView.swift
//  ProductCatalog
//

import SwiftUI

/// Product details page with complete specifications and Enquire action
struct ProductDetailView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: ProductDetailViewModel

    init(product: Product, repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: product.id, initialProduct: product, repository: repository))
    }

    init(productId: Int, repository: ProductRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId, initialProduct: nil, repository: repository))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let product = viewModel.product {
                        // Hero Image
                        ZStack {
                            Color.white
                            AsyncProductImage(urlString: product.image, contentMode: .fit)
                                .frame(height: 280)
                                .padding(16)
                        }
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                        // Meta header
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(product.category.uppercased())
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Capsule())

                                Spacer()

                                RatingBadgeView(rating: product.rating)
                            }

                            Text(product.title)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)

                            Text(product.formattedPrice)
                                .font(.title.weight(.heavy))
                                .foregroundColor(.accentColor)
                        }

                        Divider()

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Product")
                                .font(.headline)
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }

                        // Bottom padding so content is not obscured by floating Enquire bar
                        Spacer(minLength: 80)
                    } else if viewModel.isLoading {
                        ProgressView("Loading product...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text("Product Not Found")
                                .font(.headline)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            // Floating Bottom Bar with "Enquire" Action
            if let product = viewModel.product {
                bottomEnquireBar(for: product)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isEnquiryPresented) {
            if let product = viewModel.product {
                EnquirySheetView(product: product, repository: container.repository)
            }
        }
        .task {
            await viewModel.loadProduct()
        }
    }

    private func bottomEnquireBar(for product: Product) -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Price")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(product.formattedPrice)
                        .font(.headline.weight(.bold))
                }

                Button(action: { viewModel.presentEnquiry() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                        Text("Enquire")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground).opacity(0.95))
        }
    }
}
