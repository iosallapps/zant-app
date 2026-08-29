//
//  ShieldConfigurationExtension.swift
//  ZantShieldConfiguration
//
//  Created by Tudosoiu Vlad Stefan on 3/18/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private func zantShieldConfiguration() -> ShieldConfiguration {
        let backgroundColor = UIColor(red: 30.0 / 255.0, green: 27.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0) // #1E1B4B

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            backgroundColor: backgroundColor,
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(text: "Stay Focused", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "This app is blocked by Zant to help you focus.",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0),
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        zantShieldConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        zantShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        zantShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        zantShieldConfiguration()
    }
}
