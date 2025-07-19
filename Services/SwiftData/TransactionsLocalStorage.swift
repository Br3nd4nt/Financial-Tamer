import Foundation
import SwiftData

final class TransactionsLocalStorage: LocalStorageProtocol {
    typealias Item = Transaction
    
    private let modelContext: ModelContext
    
    init() throws {
        self.modelContext = SharedModelContainer.shared.modelContext
    }
    
    func getAll() async throws -> [Transaction] {
        return try await MainActor.run {
            let descriptor = FetchDescriptor<LocalTransaction>()
            let localTransactions = try modelContext.fetch(descriptor)
            return localTransactions.map { $0.toTransaction() }
        }
    }
    
    func getById(_ id: Int) async throws -> Transaction? {
        return try await MainActor.run {
            let descriptor = FetchDescriptor<LocalTransaction>(
                predicate: #Predicate<LocalTransaction> { localTransaction in
                    localTransaction.id == id
                }
            )
            let localTransaction = try modelContext.fetch(descriptor).first
            return localTransaction?.toTransaction()
        }
    }
    
    func create(_ item: Transaction) async throws {
        try await MainActor.run {
            let itemId = item.id
            let descriptor = FetchDescriptor<LocalTransaction>(
                predicate: #Predicate<LocalTransaction> { $0.id == itemId }
            )
            let existingTransactions = try modelContext.fetch(descriptor)
            if !existingTransactions.isEmpty {
                return
            }
            
            let localTransaction = LocalTransaction(from: item)
            modelContext.insert(localTransaction)
            try modelContext.save()
        }
    }
    
    func update(_ item: Transaction) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalTransaction>(
                predicate: #Predicate<LocalTransaction> { localTransaction in
                    localTransaction.id == item.id
                }
            )
            let localTransaction = try modelContext.fetch(descriptor).first
            
            if let localTransaction = localTransaction {
                localTransaction.accountId = item.accountId
                localTransaction.categoryId = item.categoryId
                localTransaction.amount = item.amount.description
                localTransaction.transactionDate = item.transactionDate
                localTransaction.comment = item.comment
                localTransaction.updatedAt = item.updatedAt
                try modelContext.save()
            } else {
                throw LocalStorageError.itemNotFound
            }
        }
    }
    
    func delete(_ id: Int) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalTransaction>(
                predicate: #Predicate<LocalTransaction> { localTransaction in
                    localTransaction.id == id
                }
            )
            let localTransactions = try modelContext.fetch(descriptor)
            
            for localTransaction in localTransactions {
                modelContext.delete(localTransaction)
            }
            try modelContext.save()
        }
    }
    
    func clear() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalTransaction>()
            let localTransactions = try modelContext.fetch(descriptor)
            
            for localTransaction in localTransactions {
                modelContext.delete(localTransaction)
            }
            try modelContext.save()
        }
    }
}

enum LocalStorageError: Error {
    case itemNotFound
    case saveFailed
} 