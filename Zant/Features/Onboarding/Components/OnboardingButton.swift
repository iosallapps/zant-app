//
//  OnboardingButton.swift
//  Zant
//
//  Standard onboarding button component inspired by Pdfino design
//

import SwiftUI

/// Standard continue button for onboarding screens with gradient background
struct OnboardingButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    @ScaledMetric(relativeTo: .body) private var buttonTextSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var buttonIconSize: CGFloat = 16

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let customIcon = icon {
                        Image(systemName: customIcon)
                            .font(.system(size: buttonIconSize, weight: .semibold))
                    }

                    Text(title)
                        .font(.system(size: buttonTextSize, weight: .semibold, design: .rounded))

                    if icon == nil {
                        Image(systemName: title == "Get Started" ? "arrow.right.circle.fill" : "arrow.right")
                            .font(.system(size: buttonIconSize, weight: .semibold))
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Main gradient background (accent to teal)
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.accent,
                            DesignTokens.Colors.accentTeal
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    // Subtle inner highlight
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DesignTokens.Colors.accent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingButton(title: "Continue") {}
        OnboardingButton(title: "Get Started") {}
    }
    .padding()
    .background(Color.black)
}
