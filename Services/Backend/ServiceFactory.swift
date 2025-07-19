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
        return TransactionsService()
    }()

    lazy var categoriesService: CategoriesProtocol = {
        if useMockServices {
            return CategoriesServiceMock.shared
        }
        return CategoriesService()
    }()

    lazy var bankAccountsService: BankAccountsProtocol = {
        if useMockServices {
            return BankAccountsServiceMock.shared
        }
        return BankAccountsService()
    }()
}
