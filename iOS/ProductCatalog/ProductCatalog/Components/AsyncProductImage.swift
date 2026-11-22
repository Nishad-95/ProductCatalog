//
//  AsyncProductImage.swift
//  ProductCatalog
//

import SwiftUI

/// Reusable asynchronous product image loader with placeholder and error fallbacks
struct AsyncProductImage: View {
    let urlString: String
    var contentMode: ContentMode = .fit

    private var targetURL: URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("fakestoreapi.com/img/") {
            let filename = trimmed.components(separatedBy: "fakestoreapi.com/img/").last ?? ""
            if !filename.isEmpty {
                return URL(string: "https://m.media-amazon.com/images/I/\(filename)")
            }
        }
        return URL(string: trimmed)
    }

    var body: some View {
        AsyncImage(url: targetURL) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                ZStack {
                    Color(.systemGray6)
                    Image(systemName: "photo")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                }
            @unknown default:
                Color(.systemGray6)
            }
        }
    }
}
