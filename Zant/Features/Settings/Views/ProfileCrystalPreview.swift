import SwiftUI

/// Cup collection preview card - tappable to view full collection
struct ProfileCrystalPreview: View {

    let earnedCrystals: [CrystalType]
    var onViewAll: () -> Void

    private var totalCups: Int { CrystalType.allCases.count }
    private var earnedCount: Int { earnedCrystals.count }

    var body: some View {
        Button(action: onViewAll) {
            ZStack {
                // Very faint background icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(DesignTokens.Colors.accent.opacity(0.05))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(20)

                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cup Collection")
                                .font(.title3.bold())
                                .foregroundStyle(.white)

                            Text("\(earnedCount) of \(totalCups) unlocked")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    // Cup preview row
                    if earnedCrystals.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(.white.opacity(0.05))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.white.opacity(0.2))
                                        )

                                    Text("Locked")
                                        .font(.system(size: 9))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            ForEach(earnedCrystals.sorted(by: { $0.tier > $1.tier }).prefix(4), id: \.self) { crystal in
                                VStack(spacing: 6) {
                                    Image(crystal.assetName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)

                                    Text(crystal.displayName)
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .lineLimit(1)
                                }
                            }

                            if earnedCount < totalCups {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(.white.opacity(0.05))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text("+\(totalCups - earnedCount)")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        )

                                    Text("More")
                                        .font(.system(size: 9))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            }
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(DesignTokens.Colors.accent)
                                .frame(width: geo.size.width * CGFloat(earnedCount) / CGFloat(totalCups))
                        }
                    }
                    .frame(height: 4)
                }
                .padding(20)
            }
            .frame(height: 180)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
