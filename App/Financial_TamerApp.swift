//
//  Financial_TamerApp.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import SwiftUI
import UIKit

// Notification for shake detection
extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIView.appearance().overrideUserInterfaceStyle = .light
        return true
    }
}

// UIWindow subclass for shake detection (used by system, not set manually)
class ShakeDetectingWindow: UIWindow {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

@main
struct Financial_TamerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            AppTabBarView()
        }
    }
}
