//
//  BankAccountsServiceMock.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class BankAccountsServiceMock: BankAccountsProtocol {
    func getBankAccount(userId: Int) async throws -> BankAccount {
        return BankAccount(id: 1, userId: 1, name: "My account", balance: 10003.7, currency: "USD", createdAt: Date.now, updatedAt: Date.now)
    }
    
    func updateBankAccount(userId: Int, newAccount: BankAccount) async throws -> BankAccount {
        return newAccount
    }
    
}
