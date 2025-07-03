//
//  TransactionsListViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import Foundation

@MainActor
class TransactionsListViewModel: ObservableObject {
    
    @Published var transactionRows: [TransactionRowModel] = []
    
    @Published var sortOption: TransactionSortOption = .byDate {
        didSet {
            transactionRows.sort(by: sortTransactions)
        }
    }
    
    private var rawTransactions: [Transaction] = []
    private var rawCategories: [Category] = []
    
    private let direction: Direction
    
    private let transactionsProtocol: TransactionsProtocol
    private let categoriesProtocol: CategoriesProtocol
    
    private var dayStart: Date = Calendar.current.startOfDay(for: Date())
    private var dayEnd: Date = {
        guard let date = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.current.startOfDay(for: Date())) else {
            print("Failled to get tomorrow date")
            return Date()
        }
        return date
    }()
    
    var total: Decimal {
        transactionRows.reduce(0) { result, row in
            if row.category.direction == direction {
                result + row.transaction.amount
            } else {
                result
            }
        }
    }
    
    init(
        direction: Direction,
        transactionsProtocol: TransactionsProtocol = TransactionsServiceMock(),
        categoriesProtocol: CategoriesProtocol = CategoriesServiceMock()
    ) {
        self.direction = direction
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
    }
    
    func loadTransactions() async {
        guard let loadedCategories = try? await categoriesProtocol.getCategories() else {
            print("Fairled to load categories")
            return
        }
        
        self.rawCategories = loadedCategories
        
        guard let loadedTransactions = try? await transactionsProtocol.getTransactionsInTimeFrame(
            userId: 1,
            startDate: dayStart,
            endDate: dayEnd
        ) else {
            print("Fairled to load transactions")
            return
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
    
    enum SortOption: String, CaseIterable {
        case byDate = "По дате"
        case byAmount = "По сумме"
    }
    
    private func sortTransactions(_ lhs: TransactionRowModel, _ rhs: TransactionRowModel) -> Bool {
        switch sortOption {
        case .byDate:
            return lhs.transaction.transactionDate > rhs.transaction.transactionDate
        case .byAmount:
            return lhs.transaction.amount > rhs.transaction.amount
        }
    }
}
