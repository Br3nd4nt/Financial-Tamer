//
//  TransactionsService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class TransactionsService: TransactionsProtocol {
    private let networkClient: NetworkClientProtocol
    private let localStorage: any LocalStorageProtocol<Transaction>
    private let backupStorage: any BackupStorageProtocol<Transaction, BackupAction>

    init(networkClient: NetworkClientProtocol = NetworkClient(), localStorage: any LocalStorageProtocol<Transaction>, backupStorage: any BackupStorageProtocol<Transaction, BackupAction>) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }

    func getTransactionsInTimeFrame(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        print("Starting getTransactionsInTimeFrame for account \(accountId)")
        // Removed backup sync on every load
        print("Making network request...")
        let endpoint = TransactionsEndpoint.getTransactionsInTimeFrame(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate
        )
        let dtos: [TransactionDTO] = try await networkClient.request(endpoint)
        print("Network request completed successfully, got \(dtos.count) transactions")
        let transactions = ModelMapper.map(dtos)

        for transaction in transactions {
            try await localStorage.create(transaction)
        }

        NetworkMonitor.shared.setOfflineMode(false)
        return transactions
    }

    private func getLocalTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let localTransactions = try await localStorage.getAll()
        let backupItems = try await backupStorage.getBackupItems()

        var allTransactions = localTransactions

        for (backupTransaction, action) in backupItems {
            switch action {
            case .create:
                if !allTransactions.contains(where: { $0.id == backupTransaction.id }) {
                    allTransactions.append(backupTransaction)
                }
            case .update:
                if let index = allTransactions.firstIndex(where: { $0.id == backupTransaction.id }) {
                    allTransactions[index] = backupTransaction
                }
            case .delete:
                allTransactions.removeAll { $0.id == backupTransaction.id }
            }
        }

        return allTransactions.filter { transaction in
            transaction.accountId == accountId &&
            transaction.transactionDate >= startDate &&
            transaction.transactionDate <= endDate
        }
    }

    func createTransaction(transaction: Transaction, account: BankAccount, category: Category) async throws -> Transaction {
        do {
            let dto = ModelMapper.mapToCreateDTO(transaction)
            print("[DEBUG] Creating transaction DTO: \(dto)")
            let encoder = JSONEncoder()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            encoder.dateEncodingStrategy = .formatted(formatter)
            let jsonData = try encoder.encode(dto)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[DEBUG] JSON body: \(jsonString)")
            } else {
                print("[DEBUG] Failed to encode CreateTransactionDTO to JSON")
            }
            let endpoint = TransactionsEndpoint.createTransaction(transaction: transaction)
            let createResponse: CreateTransactionResponseDTO = try await networkClient.request(endpoint, body: jsonData)
            let createdTransaction = ModelMapper.map(createResponse, account: account, category: category)
            try await localStorage.create(createdTransaction)
            try await backupStorage.removeFromBackup(transaction.id)
            NetworkMonitor.shared.setOfflineMode(false)
            return createdTransaction
        } catch {
            try await backupStorage.addToBackup(transaction, action: .create)
            throw error
        }
    }

    func updateTransaction(transaction: Transaction) async throws -> Transaction {
        do {
            let endpoint = TransactionsEndpoint.updateTransaction(transaction: transaction)
            let updatedTransaction: Transaction = try await networkClient.request(endpoint, body: transaction)

            try await localStorage.update(updatedTransaction)
            try await backupStorage.removeFromBackup(transaction.id)

            NetworkMonitor.shared.setOfflineMode(false)
            return updatedTransaction
        } catch {
            try await backupStorage.addToBackup(transaction, action: .update)
            throw error
        }
    }

    func deleteTransaction(id: Int) async throws {
        do {
            let endpoint = TransactionsEndpoint.deleteTransaction(id: id)
            let _: EmptyResponse = try await networkClient.request(endpoint)

            try await localStorage.delete(id)
            try await backupStorage.removeFromBackup(id)

            NetworkMonitor.shared.setOfflineMode(false)
        } catch {
            if let transaction = try await localStorage.getById(id) {
                try await backupStorage.addToBackup(transaction, action: .delete)
            }
            throw error
        }
    }

    private func syncBackupTransactions() async throws {
        let backupItems = try await backupStorage.getBackupItems()

        if backupItems.isEmpty {
            return
        }

        for (transaction, action) in backupItems {
            do {
                switch action {
                case .create:
                    let endpoint = TransactionsEndpoint.createTransaction(transaction: transaction)
                    let dto = ModelMapper.mapToCreateDTO(transaction)
                    let encoder = JSONEncoder()
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    encoder.dateEncodingStrategy = .formatted(formatter)
                    let jsonData = try encoder.encode(dto)
                    let createdTransaction: Transaction = try await networkClient.request(endpoint, body: jsonData)
                    try await localStorage.create(createdTransaction)
                    try await backupStorage.removeFromBackup(transaction.id)

                case .update:
                    let endpoint = TransactionsEndpoint.updateTransaction(transaction: transaction)
                    let updatedTransaction: Transaction = try await networkClient.request(endpoint, body: transaction)
                    try await localStorage.update(updatedTransaction)
                    try await backupStorage.removeFromBackup(transaction.id)

                case .delete:
                    let endpoint = TransactionsEndpoint.deleteTransaction(id: transaction.id)
                    let _: EmptyResponse = try await networkClient.request(endpoint)
                    try await localStorage.delete(transaction.id)
                    try await backupStorage.removeFromBackup(transaction.id)
                }
            } catch {
                print("Failed to sync backup transaction \(transaction.id): \(error)")
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpError(let statusCode, _, _):
                        if statusCode == 409 {
                            try await backupStorage.removeFromBackup(transaction.id)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Endpoints
private enum TransactionsEndpoint: Endpoint {
    case getTransactionsInTimeFrame(accountId: Int, startDate: Date, endDate: Date)
    case createTransaction(transaction: Transaction)
    case updateTransaction(transaction: Transaction)
    case deleteTransaction(id: Int)

    var baseURL: URL {
        Config.apiBaseURL
    }

    var path: String {
        switch self {
        case .getTransactionsInTimeFrame(let accountId, _, _):
            return "/transactions/account/\(accountId)/period"
        case .createTransaction:
            return "/transactions"
        case .updateTransaction(let transaction):
            return "/transactions/\(transaction.id)"
        case .deleteTransaction(let id):
            return "/transactions/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getTransactionsInTimeFrame:
            return .get
        case .createTransaction:
            return .post
        case .updateTransaction:
            return .put
        case .deleteTransaction:
            return .delete
        }
    }

    var headers: [String: String] {
        [:]
    }

    var parameters: [String: Any] {
        switch self {
        case .getTransactionsInTimeFrame(_, let startDate, let endDate):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return [
                "startDate": dateFormatter.string(from: startDate),
                "endDate": dateFormatter.string(from: endDate)
            ]
        default:
            return [:]
        }
    }
}

// MARK: - Response Types
private struct EmptyResponse: Decodable {}
