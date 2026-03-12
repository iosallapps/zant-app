//
//  ZantApp.swift
//  Zant
//
//  Created by Tudosoiu Vlad Stefan on 3/12/26.
//

import SwiftUI
import CoreData

@main
struct ZantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
