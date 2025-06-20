//
//  HistoryModelView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import Foundation
import SwiftUI

@MainActor
class HistoryModelView: ObservableObject {
    @Published var transactionRows: [TransactionRowModel] = []
    @Published var dayStart: Date {
        didSet { reloadData() }
    }
        
    @Published var dayEnd: Date {
        didSet { reloadData() }
    }
    
    private var rawTransactions: [Transaction] = []
    private var rawCategories: [Category] = []
    
    private let direction: Direction
    
    private let transactionsProtocol: TransactionsProtocol
    private let categoriesProtocol: CategoriesProtocol
    
    
    
    var total: Decimal {
        transactionRows.reduce(0) { result, row in
            if row.category.direction == direction {
                result + row.transaction.amount
            } else {
                result
            }
        }
    }
    
    init(direction: Direction, startDate: Date, endDate: Date, transactionsProtocol: TransactionsProtocol = TransactionsServiceMock(), categoriesProtocol: CategoriesProtocol = CategoriesServiceMock()) {
        self.direction = direction
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
        self.dayStart = startDate
        self.dayEnd = endDate
    }
    
    func loadTransactions() async {
        guard let loadedCategories = try? await categoriesProtocol.getCategories() else {
            fatalError("Failed to load categories")
        }
        
        self.rawCategories = loadedCategories
        
        
        guard let loadedTransactions = try? await transactionsProtocol.getTransactionsInTimeFrame(userId: 1, startDate: dayStart, endDate: dayEnd) else {
            fatalError("Failed to load transactions")
        }
        
        self.rawTransactions = loadedTransactions
        
        let categoryDict = Dictionary(uniqueKeysWithValues: rawCategories.map { ($0.id, $0) })
        
        let rows = rawTransactions.compactMap { transaction -> TransactionRowModel? in
            guard let category = categoryDict[transaction.categoryId] else {
                print("Missing category for transaction: \(transaction.id)")
                return nil
            }
            if category.direction != direction {
                return nil
            }
            return TransactionRowModel(transaction: transaction, category: category, id: transaction.id)
        }
        
        self.transactionRows = rows
    }
    
    private func reloadData() {
        print("reloaded")
        Task {
            await loadTransactions()
        }
    }
    
}
