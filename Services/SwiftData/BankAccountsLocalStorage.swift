import Foundation
import SwiftData

final class BankAccountsLocalStorage: LocalStorageProtocol {
    typealias Item = BankAccount

    private let modelContext: ModelContext

    init() throws {
        self.modelContext = SharedModelContainer.shared.modelContext
    }

    func getAll() async throws -> [BankAccount] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalBankAccount>()
            let localBankAccounts = try modelContext.fetch(descriptor)
            return localBankAccounts.map { $0.toBankAccount() }
        }
    }

    func getById(_ id: Int) async throws -> BankAccount? {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalBankAccount>(
                predicate: #Predicate<LocalBankAccount> { localBankAccount in
                    localBankAccount.id == id
                }
            )
            let localBankAccount = try modelContext.fetch(descriptor).first
            return localBankAccount?.toBankAccount()
        }
    }

    func create(_ item: BankAccount) async throws {
        try await MainActor.run {
            let itemId = item.id
            let descriptor = FetchDescriptor<LocalBankAccount>(
                predicate: #Predicate<LocalBankAccount> { $0.id == itemId }
            )
            let existingAccounts = try modelContext.fetch(descriptor)
            if !existingAccounts.isEmpty {
                return
            }

            let localBankAccount = LocalBankAccount(from: item)
            modelContext.insert(localBankAccount)
            try modelContext.save()
        }
    }

    func update(_ item: BankAccount) async throws {
        try await MainActor.run {
            let itemId = item.id
            let descriptor = FetchDescriptor<LocalBankAccount>(
                predicate: #Predicate<LocalBankAccount> { localBankAccount in
                    localBankAccount.id == itemId
                }
            )
            let localBankAccount = try modelContext.fetch(descriptor).first

            if let localBankAccount {
                localBankAccount.name = item.name
                localBankAccount.balance = item.balance.description
                localBankAccount.currency = item.currency.rawValue
                localBankAccount.updatedAt = item.updatedAt
                try modelContext.save()
            } else {
                throw LocalStorageError.itemNotFound
            }
        }
    }

    func delete(_ id: Int) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalBankAccount>(
                predicate: #Predicate<LocalBankAccount> { localBankAccount in
                    localBankAccount.id == id
                }
            )
            let localBankAccounts = try modelContext.fetch(descriptor)

            for localBankAccount in localBankAccounts {
                modelContext.delete(localBankAccount)
            }
            try modelContext.save()
        }
    }

    func clear() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalBankAccount>()
            let localBankAccounts = try modelContext.fetch(descriptor)

            for localBankAccount in localBankAccounts {
                modelContext.delete(localBankAccount)
            }
            try modelContext.save()
        }
    }
}
