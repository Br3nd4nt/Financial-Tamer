import Foundation

enum StorageMethod: String, CaseIterable {
    case swiftData = "swiftdata"
    case coreData = "coredata"

    var displayName: String {
        switch self {
        case .swiftData:
            return "SwiftData"
        case .coreData:
            return "Core Data"
        }
    }
}

final class StorageSettings {
    static let shared = StorageSettings()

    private let userDefaults = UserDefaults.standard
    private let storageMethodKey = "storage_method"
    private let lastStorageMethodKey = "last_storage_method"

    private init() {}

    var currentStorageMethod: StorageMethod {
        get {
            let rawValue = userDefaults.string(forKey: storageMethodKey) ?? StorageMethod.swiftData.rawValue
            return StorageMethod(rawValue: rawValue) ?? .swiftData
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: storageMethodKey)
        }
    }

    var lastStorageMethod: StorageMethod? {
        get {
            guard let rawValue = userDefaults.string(forKey: lastStorageMethodKey) else { return nil }
            return StorageMethod(rawValue: rawValue)
        }
        set {
            if let newValue {
                userDefaults.set(newValue.rawValue, forKey: lastStorageMethodKey)
            } else {
                userDefaults.removeObject(forKey: lastStorageMethodKey)
            }
        }
    }

    var hasStorageMethodChanged: Bool {
        guard let lastMethod = lastStorageMethod else { return false }
        return currentStorageMethod != lastMethod
    }

    func updateLastStorageMethod() {
        lastStorageMethod = currentStorageMethod
    }
}
