import Foundation
import SwiftData

@Model
final class LocalTransaction {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: String
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from transaction: Transaction) {
        self.init(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: transaction.amount.description,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
    }
    
    func toTransaction() -> Transaction {
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: Decimal(string: amount) ?? Decimal(0),
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 