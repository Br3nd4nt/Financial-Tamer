//
//  Untitled.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class TransactionsServiceMock: TransactionsProtocol {
    
    private var mockTransactions: [Transaction] = [
        Transaction(id: 1, accountId: 1, categoryId: 1, amount: 100, transactionDate: Date.now, comment: "first transaction", createdAt: Date.now, updatedAt: Date.now),
        Transaction(id: 2, accountId: 1, categoryId: 2, amount: 2000, transactionDate: Date.now, comment: "second transaction", createdAt: Date.now, updatedAt: Date.now),
        Transaction(id: 3, accountId: 1, categoryId: 3, amount: 3000, transactionDate: Date.now, comment: "third transaction", createdAt: Date.now, updatedAt: Date.now),
    ]
    
    func getTransactionsInTimeFrame(userId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        return mockTransactions.filter {$0.accountId == userId && $0.transactionDate >= startDate && $0.transactionDate <= endDate}
    }
    
    func createTransaction(transaction: Transaction) async throws -> Transaction {
        
        guard !mockTransactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.dublicatedTransaction
        }
        
        mockTransactions.append(transaction)
        return transaction
    }
    
    func updateTransaction(transaction: Transaction) async throws -> Transaction {
        
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.invalidTransaction
        }
    
        mockTransactions[index] = transaction
        
        return transaction
    }
    
    func deleteTransaction(id: Int) async throws {
        
        guard let index = mockTransactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionServiceError.invalidTransactionId
        }
        mockTransactions.remove(at: index)
    }
    
}
