//
//  Financial_TamerApp.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import SwiftUI
import UIKit

@main
struct FinancialTamerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                AppTabBarView()
                
                OfflineIndicatorView(isVisible: networkMonitor.isOfflineMode)
            }
            .task {
                await DataMigrationManager.shared.migrateDataIfNeeded()
            }
        }
    }
}
