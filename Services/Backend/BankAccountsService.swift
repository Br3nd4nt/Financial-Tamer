//
//  BankAccountsService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class BankAccountsService: BankAccountsProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func getBankAccount(userId: Int) async throws -> BankAccount {
        let endpoint = BankAccountsEndpoint.getBankAccount(userId: userId)
        let dto: BankAccountDTO = try await networkClient.request(endpoint)
        return ModelMapper.map(dto)
    }

    func updateBankAccount(userId: Int, newAccount: BankAccount) async throws -> BankAccount {
        let endpoint = BankAccountsEndpoint.updateBankAccount(userId: userId, newAccount: newAccount)
        let dto: BankAccountDTO = try await networkClient.request(endpoint, body: ModelMapper.map(newAccount))
        return ModelMapper.map(dto)
    }
}

// MARK: - Endpoints
private enum BankAccountsEndpoint: Endpoint {
    case getBankAccount(userId: Int)
    case updateBankAccount(userId: Int, newAccount: BankAccount)

    var baseURL: URL {
        Config.apiBaseURL
    }

    var path: String {
        switch self {
        case .getBankAccount(let userId):
            return "/accounts/\(userId)"
        case .updateBankAccount(let userId, _):
            return "/accounts/\(userId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getBankAccount:
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
