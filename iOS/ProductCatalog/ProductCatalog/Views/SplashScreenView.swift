//
//  SplashScreenView.swift
//  ProductCatalog
//
//  Created for Catlog MVP
//

import SwiftUI

/// Elegant animated splash screen displayed during initial app launch
struct SplashScreenView: View {
    var onFinished: () -> Void

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0.0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 16
    @State private var textOpacity: Double = 0.0
    @State private var footerOpacity: Double = 0.0
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            // Adaptive background with subtle radial highlight
            Color(.systemBackground)
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.accentColor.opacity(0.12),
                    Color.clear
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Animated Logo Icon
                ZStack {
                    // Radiant aura ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.5), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Soft ambient shadow glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.35), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: isPulsing ? 18 : 10)

                    // Premium Icon Badge
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor,
                                    Color.blue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.accentColor.opacity(0.35), radius: 16, x: 0, y: 8)

                    // Shopping Bag Icon
                    Image(systemName: "bag.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                // App Brand Typography
                VStack(spacing: 6) {
                    Text("Catlog")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.primary)

                    Text("Discover curated products")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                        .tracking(0.3)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()

                // Bottom loading indicator
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.accentColor.opacity(0.8))
                            .frame(width: 6, height: 6)
                            .scaleEffect(isPulsing ? 1.2 : 0.7)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.18),
                                value: isPulsing
                            )
                    }
                }
                .padding(.bottom, 36)
                .opacity(footerOpacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Optional early tap to skip
            onFinished()
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // Stage 1: Icon spring bounce in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65, blendDuration: 0)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        // Stage 2: Glow ring pulse outward
        withAnimation(.easeOut(duration: 0.9).delay(0.15)) {
            ringScale = 1.3
            ringOpacity = 0.75
        }

        withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
            ringOpacity = 0.0
        }

        // Stage 3: Title and tagline slide and fade up
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOffset = 0
            textOpacity = 1.0
        }

        // Stage 4: Footer dots fade in and begin pulsing
        withAnimation(.easeIn(duration: 0.4).delay(0.55)) {
            footerOpacity = 1.0
            isPulsing = true
        }

        // Stage 5: Automatically complete and transition to Home screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            onFinished()
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
