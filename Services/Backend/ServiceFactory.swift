//
//  ServiceFactory.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class ServiceFactory {
    static let shared = ServiceFactory()
    private init() {}

    // MARK: - Configuration
    private let useMockServices = false

    // MARK: - Services
    lazy var transactionsService: TransactionsProtocol = {
        if useMockServices {
            return TransactionsServiceMock.shared
        }
        do {
            return try createTransactionsService()
        } catch {
            print("Failed to initialize TransactionsService: \(error)")
            return TransactionsServiceMock.shared
        }
    }()

    lazy var categoriesService: CategoriesProtocol = {
        if useMockServices {
            return CategoriesServiceMock.shared
        }
        do {
            return try createCategoriesService()
        } catch {
            print("Failed to initialize CategoriesService: \(error)")
            return CategoriesServiceMock.shared
        }
    }()

    lazy var bankAccountsService: BankAccountsProtocol = {
        if useMockServices {
            return BankAccountsServiceMock.shared
        }
        do {
            return try createBankAccountsService()
        } catch {
            print("Failed to initialize BankAccountsService: \(error)")
            return BankAccountsServiceMock.shared
        }
    }()

    private func createTransactionsService() throws -> TransactionsService {
        let storageMethod = StorageSettings.shared.currentStorageMethod

        switch storageMethod {
        case .swiftData:
            return TransactionsService(
                localStorage: try TransactionsLocalStorage(),
                backupStorage: try TransactionsBackupStorage()
            )
        case .coreData:
            return TransactionsService(
                localStorage: TransactionsCoreDataStorage(),
                backupStorage: TransactionsCoreDataBackupStorage()
            )
        }
    }

    private func createBankAccountsService() throws -> BankAccountsService {
        let storageMethod = StorageSettings.shared.currentStorageMethod

        switch storageMethod {
        case .swiftData:
            return BankAccountsService(
                localStorage: try BankAccountsLocalStorage(),
                backupStorage: try BankAccountsBackupStorage()
            )
        case .coreData:
            return BankAccountsService(
                localStorage: BankAccountsCoreDataStorage(),
                backupStorage: BankAccountsCoreDataBackupStorage()
            )
        }
    }

    private func createCategoriesService() throws -> CategoriesService {
        let storageMethod = StorageSettings.shared.currentStorageMethod

        switch storageMethod {
        case .swiftData:
            return CategoriesService(localStorage: try CategoriesLocalStorage())
        case .coreData:
            return CategoriesService(localStorage: CategoriesCoreDataStorage())
        }
    }
}
