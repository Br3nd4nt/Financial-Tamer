//
//  TransactionsService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class TransactionsService: TransactionsProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func getTransactionsInTimeFrame(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let endpoint = TransactionsEndpoint.getTransactionsInTimeFrame(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate
        )
        let dtos: [TransactionDTO] = try await networkClient.request(endpoint)
        return ModelMapper.map(dtos)
    }

    func createTransaction(transaction: Transaction) async throws -> Transaction {
        let endpoint = TransactionsEndpoint.createTransaction(transaction: transaction)
        return try await networkClient.request(endpoint, body: transaction)
    }

    func updateTransaction(transaction: Transaction) async throws -> Transaction {
        let endpoint = TransactionsEndpoint.updateTransaction(transaction: transaction)
        return try await networkClient.request(endpoint, body: transaction)
    }

    func deleteTransaction(id: Int) async throws {
        let endpoint = TransactionsEndpoint.deleteTransaction(id: id)
        let _: EmptyResponse = try await networkClient.request(endpoint)
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
