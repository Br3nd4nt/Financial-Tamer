import Foundation
import SwiftData

final class TransactionsBackupStorage: BackupStorageProtocol {
    typealias Item = Transaction
    typealias Action = BackupAction
    
    private let modelContext: ModelContext
    
    init() throws {
        self.modelContext = SharedModelContainer.shared.modelContext
    }
    
    func addToBackup(_ item: Transaction, action: BackupAction) async throws {
        try await MainActor.run {
            let backupTransaction = BackupTransaction(from: item, action: action)
            modelContext.insert(backupTransaction)
            try modelContext.save()
        }
    }
    
    func getBackupItems() async throws -> [(item: Transaction, action: BackupAction)] {
        return try await MainActor.run {
            let descriptor = FetchDescriptor<BackupTransaction>()
            let backupTransactions = try modelContext.fetch(descriptor)
            return backupTransactions.map { (item: $0.toTransaction(), action: $0.backupAction) }
        }
    }
    
    func removeFromBackup(_ itemId: Int) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<BackupTransaction>(
                predicate: #Predicate<BackupTransaction> { $0.id == itemId }
            )
            let backupTransactions = try modelContext.fetch(descriptor)
            
            for backupTransaction in backupTransactions {
                modelContext.delete(backupTransaction)
            }
            try modelContext.save()
        }
    }
    
    func clearBackup() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<BackupTransaction>()
            let backupTransactions = try modelContext.fetch(descriptor)
            
            for backupTransaction in backupTransactions {
                modelContext.delete(backupTransaction)
            }
            try modelContext.save()
        }
    }
} 