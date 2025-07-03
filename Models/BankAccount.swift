//
//  BankAccount.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    var currency: Currency
    let createdAt: Date
    let updatedAt: Date

    init(id: Int, userId: Int, name: String, balance: Decimal, currency: Currency, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = Currency(rawValue: currency) ?? .rub
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
