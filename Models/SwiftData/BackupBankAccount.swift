import Foundation
import SwiftData

@Model
final class BackupBankAccount {
    var id: Int
    var userId: Int
    var name: String
    var balance: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    var action: String

    init(id: Int, userId: Int, name: String, balance: String, currency: String, createdAt: Date, updatedAt: Date, action: BackupAction) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.action = action.rawValue
    }

    convenience init(from bankAccount: BankAccount, action: BackupAction) {
        self.init(
            id: bankAccount.id,
            userId: bankAccount.userId,
            name: bankAccount.name,
            balance: bankAccount.balance.description,
            currency: bankAccount.currency.rawValue,
            createdAt: bankAccount.createdAt,
            updatedAt: bankAccount.updatedAt,
            action: action
        )
    }

    func toBankAccount() -> BankAccount {
        BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: Decimal(string: balance) ?? Decimal.zero,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var backupAction: BackupAction {
        BackupAction(rawValue: action) ?? .create
    }
}
