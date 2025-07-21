import Foundation
import SwiftData

final class SharedModelContainer {
    static let shared = SharedModelContainer()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        let schema = Schema([
            LocalTransaction.self,
            BackupTransaction.self,
            LocalBankAccount.self,
            BackupBankAccount.self,
            LocalCategory.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
