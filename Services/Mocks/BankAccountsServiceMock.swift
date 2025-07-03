//
//  BankAccountsServiceMock.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class BankAccountsServiceMock: BankAccountsProtocol {
    private var mockAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "My account",
        balance: 10_003.7,
        currency: "USD",
        createdAt: Date.now,
        updatedAt: Date.now
    )

    func getBankAccount(userId: Int) async throws -> BankAccount {
        mockAccount
    }

    func updateBankAccount(userId: Int, newAccount: BankAccount) async throws -> BankAccount {
        mockAccount = newAccount
        return mockAccount
    }
}
