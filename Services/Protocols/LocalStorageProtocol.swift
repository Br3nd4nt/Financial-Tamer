import Foundation

protocol LocalStorageProtocol<Item> {
    associatedtype Item
    
    func getAll() async throws -> [Item]
    func getById(_ id: Int) async throws -> Item?
    func create(_ item: Item) async throws
    func update(_ item: Item) async throws
    func delete(_ id: Int) async throws
    func clear() async throws
}

protocol BackupStorageProtocol<Item, Action> {
    associatedtype Item
    associatedtype Action
    
    func addToBackup(_ item: Item, action: Action) async throws
    func getBackupItems() async throws -> [(item: Item, action: Action)]
    func removeFromBackup(_ itemId: Int) async throws
    func clearBackup() async throws
}

enum BackupAction {
    case create
    case update
    case delete
} 