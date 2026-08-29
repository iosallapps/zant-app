import SwiftUI

/// Full cups collection view showing all cups with unlock requirements
struct CupsCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    let earnedCrystals: [CrystalType]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cup Collection")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)

                            Text("\(earnedCrystals.count) of \(CrystalType.allCases.count) unlocked")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Grid of all cups
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CrystalType.allCases, id: \.self) { crystal in
                            cupCard(crystal, isEarned: earnedCrystals.contains(crystal))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func cupCard(_ crystal: CrystalType, isEarned: Bool) -> some View {
        ZStack {
            // Very faint background icon
            Image(systemName: isEarned ? "trophy.fill" : "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(isEarned ? crystal.glowColor.opacity(0.05) : Color.white.opacity(0.03))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(10)

            VStack(spacing: 12) {
                // Cup image
                if isEarned {
                    Image(crystal.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 70)
                } else {
                    ZStack {
                        Image(crystal.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 70)
                            .saturation(0)
                            .opacity(0.2)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                VStack(spacing: 4) {
                    Text(crystal.displayName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isEarned ? .white : .white.opacity(0.5))

                    Text(crystal.tier.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(isEarned ? crystal.glowColor : .white.opacity(0.3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(isEarned ? crystal.glowColor.opacity(0.15) : .white.opacity(0.05))
                        .clipShape(Capsule())
                }

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                VStack(spacing: 2) {
                    if isEarned {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(DesignTokens.Colors.success)
                            Text("Unlocked")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(DesignTokens.Colors.success)
                        }
                    } else {
                        Text("Focus for")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("\(crystal.requiredSessionMinutes) minutes")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 240)
        .glassEffect(in: .rect(cornerRadius: 20))
    }
}

#Preview {
    CupsCollectionView(earnedCrystals: [.citrine, .moonstone, .amethyst])
}
