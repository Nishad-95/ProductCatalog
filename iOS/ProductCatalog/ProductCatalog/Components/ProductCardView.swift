//
//  ProductCardView.swift
//  ProductCatalog
//

import SwiftUI

/// Reusable product card tile for grids and lists
struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // White image container with gentle inset from the card edge
            AsyncProductImage(urlString: product.image, contentMode: .fit)
                .frame(height: 135)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                // Category Tag
                Text(product.category.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                // Title
                Text(product.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 38, alignment: .topLeading)

                Spacer(minLength: 6)

                // Rating & Price footer
                HStack(alignment: .bottom) {
                    Text(product.formattedPrice)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primary)

                    Spacer()

                    RatingBadgeView(rating: product.rating, showCount: false)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
