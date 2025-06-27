//
//  Financial_TamerApp.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import SwiftUI
import UIKit

@main
struct Financial_TamerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            AppTabBarView()
        }
    }
}
