import Foundation
import SwiftData

@Model
final class LocalBankAccount {
    var id: Int
    var name: String
    var userId: Int
    var balance: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, userId: Int, name: String, balance: String, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from bankAccount: BankAccount) {
        self.init(
            id: bankAccount.id,
            userId: bankAccount.userId,
            name: bankAccount.name,
            balance: bankAccount.balance.description,
            currency: bankAccount.currency.rawValue,
            createdAt: bankAccount.createdAt,
            updatedAt: bankAccount.updatedAt
        )
    }
    
    func toBankAccount() -> BankAccount {
        return BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: Decimal(string: balance) ?? Decimal(0),
            currency: Currency(rawValue: currency) ?? .rub,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 