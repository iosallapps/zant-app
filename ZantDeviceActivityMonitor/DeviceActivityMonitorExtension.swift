//
//  DeviceActivityMonitorExtension.swift
//  ZantDeviceActivityMonitor
//
//  Created by Tudosoiu Vlad Stefan on 3/18/26.
//

import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore(named: .init(SharedBlockingConstants.scheduleStoreName))
    private let storage = SharedBlockingStorage.shared

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        // Load the selected apps from shared app group container
        guard let data = storage.loadSelectedAppsData(),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        // Apply shields to selected apps
        store.shield.applications = selection.applicationTokens
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        // Load and save strictness-based blocking state
        let strictness = storage.loadStrictness() ?? "normal"
        let state = BlockingState(
            isBlocking: true,
            sessionMode: nil,
            expiresAt: nil,
            strictness: strictness
        )
        storage.saveBlockingState(state)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Remove all shields
        store.clearAllSettings()

        // Update shared blocking state
        storage.saveBlockingState(BlockingState(isBlocking: false))
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // Handle the event reaching its threshold.
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)

        // Handle the warning before the interval starts.
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        // Handle the warning before the interval ends.
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)

        // Handle the warning before the event reaches its threshold.
    }
}
