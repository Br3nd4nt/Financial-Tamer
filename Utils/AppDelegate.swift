import UIKit

// swiftlint:disable all
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIView.appearance().overrideUserInterfaceStyle = .light
        return true
    }
}
// swiftlint:enable all
