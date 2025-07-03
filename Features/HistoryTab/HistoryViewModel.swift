//
//  HistoryModelView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import Foundation
import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var transactionRows: [TransactionFull] = []
    @Published var dayStart: Date {
        didSet { reloadData() }
    }

    @Published var dayEnd: Date {
        didSet { reloadData() }
    }

    @Published var sortOption: TransactionSortOption = .byDate {
        didSet {
            transactionRows.sort(by: sortTransactions)
        }
    }

    private var rawTransactions: [Transaction] = []
    private var rawCategories: [Category] = []
    private var account: BankAccount?

    private let direction: Direction

    private let transactionsProtocol: TransactionsProtocol
    private let categoriesProtocol: CategoriesProtocol
    private let bankAccountsProtocol: BankAccountsProtocol

    var total: Decimal {
        transactionRows.reduce(0) { result, row in
            if row.category.direction == direction {
                result + row.amount
            } else {
                result
            }
        }
    }

    init(
        direction: Direction,
        startDate: Date,
        endDate: Date,
        transactionsProtocol: TransactionsProtocol = TransactionsServiceMock.shared,
        categoriesProtocol: CategoriesProtocol = CategoriesServiceMock.shared,
        bankAccountsProtocol: BankAccountsProtocol = BankAccountsServiceMock.shared
    ) {
        self.direction = direction
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        self.dayStart = startDate
        self.dayEnd = endDate
    }

    func loadTransactions() async {
        guard let loadedCategories = try? await categoriesProtocol.getCategories() else {
            print("Failed to load categories")
            return
        }

        self.rawCategories = loadedCategories

        guard let loadedAccount = try? await bankAccountsProtocol.getBankAccount(userId: 1) else {
            print("Failed to load bank account")
            return
        }
        self.account = loadedAccount

        guard let loadedTransactions = try? await transactionsProtocol.getTransactionsInTimeFrame(
            userId: 1,
            startDate: dayStart,
            endDate: dayEnd
        ) else {
            print("Failed to load transactions")
            return
        }

        self.rawTransactions = loadedTransactions

        let categoryDict = Dictionary(uniqueKeysWithValues: rawCategories.map { ($0.id, $0) })

        let rows = rawTransactions.compactMap { transaction -> TransactionFull? in
            guard let category = categoryDict[transaction.categoryId] else {
                print("Missing category for transaction: \(transaction.id)")
                return nil
            }
            if category.direction != direction {
                return nil
            }
            guard let account = self.account else {
                print("No account loaded for transaction: \(transaction.id)")
                return nil
            }
            return TransactionFull(transaction: transaction, account: account, category: category)
        }

        self.transactionRows = rows
    }

    private func reloadData() {
        Task {
            await loadTransactions()
            transactionRows.sort(by: sortTransactions)
        }
    }

    private func sortTransactions(_ lhs: TransactionFull, _ rhs: TransactionFull) -> Bool {
        switch sortOption {
        case .byDate:
            return lhs.transactionDate > rhs.transactionDate
        case .byAmount:
            return lhs.amount > rhs.amount
        }
    }
}
