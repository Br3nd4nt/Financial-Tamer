//
//  BankAccountsProtocol.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

protocol BankAccountsProtocol {
    func getBankAccount() async throws -> BankAccount
    func updateBankAccount(userId: Int, newAccount: BankAccount) async throws -> BankAccount
}
