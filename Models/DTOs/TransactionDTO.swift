import Foundation

struct TransactionDTO: Codable {
    let id: Int
    let account: BankAccountDTO
    let category: CategoryDTO
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}

struct CreateTransactionDTO: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: Date
    let comment: String
}
