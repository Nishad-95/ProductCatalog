//
//  RatingBadgeView.swift
//  ProductCatalog
//

import SwiftUI

/// Compact badge displaying star rating and optional review count
struct RatingBadgeView: View {
    let rating: ProductRating
    var showCount: Bool = true

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundColor(.orange)

            Text(String(format: "%.1f", rating.rate))
                .font(.caption.weight(.semibold))

            if showCount {
                Text("(\(rating.count))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.orange.opacity(0.12))
        .clipShape(Capsule())
    }
}
