import SwiftUI

/// General settings section with Daily Target and Notifications rows.
struct GeneralSettingsSection: View {

    let formattedDailyTarget: String
    let hasNotificationPermission: Bool
    var onDailyTarget: () -> Void
    var onNotifications: () -> Void

    var body: some View {
        SettingsSection(title: Strings.Profile.general) {
            VStack(spacing: 0) {
                Button {
                    onDailyTarget()
                } label: {
                    SettingsRow(icon: "target", title: Strings.Profile.dailyTarget, value: formattedDailyTarget)
                }
                .buttonStyle(SettingsRowButtonStyle())
                SectionDivider()
                Button {
                    onNotifications()
                } label: {
                    SettingsRow(
                        icon: "bell.fill",
                        title: Strings.Profile.notifications,
                        value: hasNotificationPermission ? Strings.Profile.on : Strings.Profile.off
                    )
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
        }
    }
}
