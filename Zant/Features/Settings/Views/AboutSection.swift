import SwiftUI
import StoreKit

/// About section with version info, privacy policy, terms of service, and rate app.
struct AboutSection: View {

    var onRateApp: () -> Void

    var body: some View {
        SettingsSection(title: Strings.Profile.about) {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: Strings.Profile.version,
                    value: Strings.Profile.versionNumber,
                    showChevron: false
                )
                SectionDivider()
                if let privacyURL = URL(string: Strings.URLs.privacyPolicy) {
                    Link(destination: privacyURL) {
                        SettingsRow(icon: "lock.shield.fill", title: Strings.Profile.privacyPolicy)
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
                SectionDivider()
                if let termsURL = URL(string: Strings.URLs.termsOfService) {
                    Link(destination: termsURL) {
                        SettingsRow(icon: "doc.text.fill", title: Strings.Profile.termsOfService)
                    }
                    .buttonStyle(SettingsRowButtonStyle())
                }
                SectionDivider()
                Button {
                    onRateApp()
                } label: {
                    SettingsRow(icon: "star.fill", title: Strings.Profile.rateApp)
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
        }
    }
}
