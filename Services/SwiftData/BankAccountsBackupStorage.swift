import Foundation
import SwiftData

final class BankAccountsBackupStorage: BackupStorageProtocol {
    typealias Item = BankAccount
    typealias Action = BackupAction

    private let modelContext: ModelContext

    init() throws {
        self.modelContext = SharedModelContainer.shared.modelContext
    }

    func addToBackup(_ item: BankAccount, action: BackupAction) async throws {
        try await MainActor.run {
            let backupBankAccount = BackupBankAccount(from: item, action: action)
            modelContext.insert(backupBankAccount)
            try modelContext.save()
        }
    }

    func getBackupItems() async throws -> [(item: BankAccount, action: BackupAction)] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<BackupBankAccount>()
            let backupBankAccounts = try modelContext.fetch(descriptor)
            return backupBankAccounts.map { (item: $0.toBankAccount(), action: $0.backupAction) }
        }
    }

    func removeFromBackup(_ itemId: Int) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<BackupBankAccount>(
                predicate: #Predicate<BackupBankAccount> { $0.id == itemId }
            )
            let backupBankAccounts = try modelContext.fetch(descriptor)

            for backupBankAccount in backupBankAccounts {
                modelContext.delete(backupBankAccount)
            }
            try modelContext.save()
        }
    }

    func clearBackup() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<BackupBankAccount>()
            let backupBankAccounts = try modelContext.fetch(descriptor)

            for backupBankAccount in backupBankAccounts {
                modelContext.delete(backupBankAccount)
            }
            try modelContext.save()
        }
    }
}
