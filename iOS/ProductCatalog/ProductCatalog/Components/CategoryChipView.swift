//
//  CategoryChipView.swift
//  ProductCatalog
//

import SwiftUI

/// Reusable category chip button for horizontal category carousels
struct CategoryChipView: View {
    let title: String
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: iconForCategory(title))
                    .font(.caption)
                Text(title.capitalized)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.accentColor : Color(.separator).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.accentColor.opacity(0.25) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "all":
            return "square.grid.2x2"
        case "electronics":
            return "tv"
        case "jewelery", "jewelry":
            return "sparkles"
        case "men's clothing":
            return "tshirt"
        case "women's clothing":
            return "bag"
        default:
            return "tag"
        }
    }
}
