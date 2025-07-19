import Foundation
import SwiftData

@Model
final class BackupTransaction {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: String
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    var action: String

    init(id: Int, accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String, createdAt: Date, updatedAt: Date, action: BackupAction) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.action = action.rawValue
    }

    convenience init(from transaction: Transaction, action: BackupAction) {
        self.init(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount.description,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            action: action
        )
    }

    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: Decimal(string: amount) ?? Decimal.zero,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var backupAction: BackupAction {
        BackupAction(rawValue: action) ?? .create
    }
}

extension BackupAction {
    var rawValue: String {
        switch self {
        case .create:
            return "create"
        case .update:
            return "update"
        case .delete:
            return "delete"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "create":
            self = .create
        case "update":
            self = .update
        case "delete":
            self = .delete
        default:
            return nil
        }
    }
}
