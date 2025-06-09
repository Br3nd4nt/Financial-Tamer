//
//  Untitled.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class TransactionsServiceMock: TransactionsProtocol {
    func getTransactionsInTimeFrame(userId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        return [
            Transaction(id: 1, accountId: userId, categoryId: 1, amount: 100, transactionDate: startDate, comment: "first transaction", createdAt: startDate, updatedAt: startDate),
            Transaction(id: 2, accountId: userId, categoryId: 2, amount: 200, transactionDate: endDate, comment: "second transaction", createdAt: endDate, updatedAt: endDate)
        ]
    }
    
    func createTransaction(transaction: Transaction) async throws -> Transaction {
        return transaction
    }
    
    func updateTransaction(transaction: Transaction) async throws -> Transaction {
        return transaction
    }
    
    func deleteTransaction(id: Int) async throws {
        
    }
    
}
