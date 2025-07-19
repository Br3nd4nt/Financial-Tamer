//
//  TransactionsProtocol.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

protocol TransactionsProtocol {
    func getTransactionsInTimeFrame(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction]
    func createTransaction(transaction: Transaction) async throws -> Transaction
    func updateTransaction(transaction: Transaction) async throws -> Transaction
    func deleteTransaction(id: Int) async throws
}

enum TransactionServiceError: Error {
    case invalidTransaction
    case dublicatedTransaction
    case invalidTransactionId
}
