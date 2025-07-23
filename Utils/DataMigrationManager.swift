import Foundation

final class DataMigrationManager {
    static let shared = DataMigrationManager()

    private init() {}

    func migrateDataIfNeeded() async {
        let settings = StorageSettings.shared

        guard settings.hasStorageMethodChanged else {
            return
        }

        do {
            try await performMigration(from: settings.lastStorageMethod ?? .swiftData, to: settings.currentStorageMethod)
            settings.updateLastStorageMethod()
        } catch {
            print("Data migration failed: \(error)")
        }
    }

    private func performMigration(from oldMethod: StorageMethod, to newMethod: StorageMethod) async throws {
        print("Starting data migration from \(oldMethod.displayName) to \(newMethod.displayName)")

        switch (oldMethod, newMethod) {
        case (.swiftData, .coreData):
            try await migrateFromSwiftDataToCoreData()
        case (.coreData, .swiftData):
            try await migrateFromCoreDataToSwiftData()
        default:
            break
        }

        print("Data migration completed successfully")
    }

    private func migrateFromSwiftDataToCoreData() async throws {
        let swiftDataTransactions = try await getSwiftDataTransactions()
        let swiftDataBankAccounts = try await getSwiftDataBankAccounts()
        let swiftDataCategories = try await getSwiftDataCategories()

        let coreDataTransactionsStorage = TransactionsCoreDataStorage()
        let coreDataBankAccountsStorage = BankAccountsCoreDataStorage()
        let coreDataCategoriesStorage = CategoriesCoreDataStorage()

        for transaction in swiftDataTransactions {
            try await coreDataTransactionsStorage.create(transaction)
        }

        for bankAccount in swiftDataBankAccounts {
            try await coreDataBankAccountsStorage.create(bankAccount)
        }

        for category in swiftDataCategories {
            try await coreDataCategoriesStorage.create(category)
        }

        try await clearSwiftData()
    }

    private func migrateFromCoreDataToSwiftData() async throws {
        let coreDataTransactions = try await getCoreDataTransactions()
        let coreDataBankAccounts = try await getCoreDataBankAccounts()
        let coreDataCategories = try await getCoreDataCategories()

        let swiftDataTransactionsStorage = try TransactionsLocalStorage()
        let swiftDataBankAccountsStorage = try BankAccountsLocalStorage()
        let swiftDataCategoriesStorage = try CategoriesLocalStorage()

        for transaction in coreDataTransactions {
            try await swiftDataTransactionsStorage.create(transaction)
        }

        for bankAccount in coreDataBankAccounts {
            try await swiftDataBankAccountsStorage.create(bankAccount)
        }

        for category in coreDataCategories {
            try await swiftDataCategoriesStorage.create(category)
        }

        try await clearCoreData()
    }

    private func getSwiftDataTransactions() async throws -> [Transaction] {
        let storage = try TransactionsLocalStorage()
        return try await storage.getAll()
    }

    private func getSwiftDataBankAccounts() async throws -> [BankAccount] {
        let storage = try BankAccountsLocalStorage()
        return try await storage.getAll()
    }

    private func getSwiftDataCategories() async throws -> [Category] {
        let storage = try CategoriesLocalStorage()
        return try await storage.getAll()
    }

    private func getCoreDataTransactions() async throws -> [Transaction] {
        let storage = TransactionsCoreDataStorage()
        return try await storage.getAll()
    }

    private func getCoreDataBankAccounts() async throws -> [BankAccount] {
        let storage = BankAccountsCoreDataStorage()
        return try await storage.getAll()
    }

    private func getCoreDataCategories() async throws -> [Category] {
        let storage = CategoriesCoreDataStorage()
        return try await storage.getAll()
    }

    private func clearSwiftData() async throws {
        let transactionsStorage = try TransactionsLocalStorage()
        let bankAccountsStorage = try BankAccountsLocalStorage()
        let categoriesStorage = try CategoriesLocalStorage()

        try await transactionsStorage.clear()
        try await bankAccountsStorage.clear()
        try await categoriesStorage.clear()
    }

    private func clearCoreData() async throws {
        let transactionsStorage = TransactionsCoreDataStorage()
        let bankAccountsStorage = BankAccountsCoreDataStorage()
        let categoriesStorage = CategoriesCoreDataStorage()

        try await transactionsStorage.clear()
        try await bankAccountsStorage.clear()
        try await categoriesStorage.clear()
    }
}
