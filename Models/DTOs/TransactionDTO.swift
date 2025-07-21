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
