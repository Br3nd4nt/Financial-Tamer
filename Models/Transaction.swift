//
//  Transaction.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    let updatedAt: Date
}

struct TransactionFull: Identifiable, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    let updatedAt: Date

    init(transaction: Transaction, account: BankAccount, category: Category) {
        self.id = transaction.id
        self.account = account
        self.category = category
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }
}
