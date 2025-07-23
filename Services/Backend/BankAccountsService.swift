//
//  BankAccountsService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class BankAccountsService: BankAccountsProtocol {
    private let networkClient: NetworkClientProtocol
    private let localStorage: any LocalStorageProtocol<BankAccount>
    private let backupStorage: any BackupStorageProtocol<BankAccount, BackupAction>

    init(networkClient: NetworkClientProtocol = NetworkClient(), localStorage: any LocalStorageProtocol<BankAccount>, backupStorage: any BackupStorageProtocol<BankAccount, BackupAction>) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }

    func updateBankAccount(userId: Int, newAccount: BankAccount) async throws -> BankAccount {
        do {
            let endpoint = BankAccountsEndpoint.updateBankAccount(userId: userId, newAccount: newAccount)
            let dto: BankAccountDTO = try await networkClient.request(endpoint, body: ModelMapper.map(newAccount))
            let updatedBankAccount = ModelMapper.map(dto)

            try await localStorage.update(updatedBankAccount)
            try await backupStorage.removeFromBackup(newAccount.id)
            NetworkMonitor.shared.setOfflineMode(false)

            return updatedBankAccount
        } catch {
            print("BankAccountsService.updateBankAccount failed: \(error)")
            if let networkError = error as? NetworkError {
                switch networkError {
                case .invalidRequest, .invalidResponse, .noData, .decodingError:
                    print("Setting offline mode due to network error: \(networkError)")
                    NetworkMonitor.shared.setOfflineMode(true)
                case .httpError(let statusCode, _, _):
                    print("HTTP error with status code: \(statusCode)")
                    if statusCode >= 500 {
                        NetworkMonitor.shared.setOfflineMode(true)
                    } else {
                        NetworkMonitor.shared.setOfflineMode(false)
                    }
                }
            } else if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled, retrying...")
                throw error
            } else {
                print("Setting offline mode due to unknown error: \(error)")
                NetworkMonitor.shared.setOfflineMode(true)
            }
            try await backupStorage.addToBackup(newAccount, action: .update)
            throw error
        }
    }

    func getBankAccount() async throws -> BankAccount {
        do {
            let endpoint = BankAccountsEndpoint.getAllBankAccounts
            let dtos: [BankAccountDTO] = try await networkClient.request(endpoint)
            let bankAccounts = ModelMapper.map(dtos)
            guard let firstAccount = bankAccounts.first else {
                throw NSError(domain: "BankAccountsService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No bank accounts found"])
            }
            // Optionally update local storage
            try await localStorage.clear()
            try await localStorage.create(firstAccount)
            NetworkMonitor.shared.setOfflineMode(false)
            return firstAccount
        } catch {
            print("BankAccountsService.getBankAccount failed: \(error)")
            NetworkMonitor.shared.setOfflineMode(true)
            let localAccounts = try await localStorage.getAll()
            guard let firstAccount = localAccounts.first else {
                throw NSError(domain: "BankAccountsService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No local bank accounts found"])
            }
            return firstAccount
        }
    }

    private func syncBackupBankAccounts() async throws {
        let backupItems = try await backupStorage.getBackupItems()

        for (bankAccount, action) in backupItems {
            do {
                switch action {
                case .create:
                    let endpoint = BankAccountsEndpoint.updateBankAccount(userId: bankAccount.userId, newAccount: bankAccount)
                    let dto: BankAccountDTO = try await networkClient.request(endpoint, body: ModelMapper.map(bankAccount))
                    let createdBankAccount = ModelMapper.map(dto)
                    try await localStorage.create(createdBankAccount)
                    try await backupStorage.removeFromBackup(bankAccount.id)

                case .update:
                    let endpoint = BankAccountsEndpoint.updateBankAccount(userId: bankAccount.userId, newAccount: bankAccount)
                    let dto: BankAccountDTO = try await networkClient.request(endpoint, body: ModelMapper.map(bankAccount))
                    let updatedBankAccount = ModelMapper.map(dto)
                    try await localStorage.update(updatedBankAccount)
                    try await backupStorage.removeFromBackup(bankAccount.id)

                case .delete:
                    // For bank accounts, we don't have a delete endpoint, so we'll just remove from backup
                    try await backupStorage.removeFromBackup(bankAccount.id)
                }
            } catch {
                print("Failed to sync backup bank account \(bankAccount.id): \(error)")
            }
        }
    }
}

// MARK: - Endpoints
private enum BankAccountsEndpoint: Endpoint {
    case getAllBankAccounts
    case updateBankAccount(userId: Int, newAccount: BankAccount)

    var baseURL: URL {
        Config.apiBaseURL
    }

    var path: String {
        switch self {
        case .getAllBankAccounts:
            return "/accounts"
        case .updateBankAccount(let userId, _):
            return "/accounts/\(userId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getAllBankAccounts:
            return .get
        case .updateBankAccount:
            return .put
        }
    }

    var headers: [String: String] {
        [:]
    }

    var parameters: [String: Any] {
        [:]
    }
}
