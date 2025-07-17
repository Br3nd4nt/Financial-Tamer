//
//  AnalyticsViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 10.07.2025.
//

import Foundation
import UIKit

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var categoryRows: [CategoryAnalytics] = []

    @Published var transactionRows: [TransactionFull] = []

    @Published var dayStart: Date {
        didSet {
            reloadData()
        }
    }

    @Published var dayEnd: Date {
        didSet {
            reloadData()
        }
    }

    @Published var sortOption: TransactionSortOption = .byAmount {
        didSet {
            categoryRows.sort(by: sortCategories)
        }
    }

    private let direction: Direction

    private var rawTransactions: [Transaction] = []
    private var rawCategories: [Category] = []
    private var account: BankAccount?

    private let transactionsProtocol: TransactionsProtocol
    private let categoriesProtocol: CategoriesProtocol
    private let bankAccountsProtocol: BankAccountsProtocol

    var onReloadData: (() -> Void)?
    var setStartDateForPicker: ((Date) -> Void)?
    var setEndDateForPicker: ((Date) -> Void)?

    init(
        direction: Direction,
        startDate: Date = Date(),
        endDate: Date = Date(),
        transactionsProtocol: TransactionsProtocol = TransactionsServiceMock.shared,
        categoriesProtocol: CategoriesProtocol = CategoriesServiceMock.shared,
        bankAccountsProtocol: BankAccountsProtocol = BankAccountsServiceMock.shared,
        onReloadData: (() -> Void)? = nil
    ) {
        self.direction = direction
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        self.dayStart = startDate.startOfDay
        self.dayEnd = endDate.endOfDay
        self.onReloadData = onReloadData
    }

    var total: Decimal {
        transactionRows.reduce(0) { result, row in
            if row.category.direction == direction {
                result + row.amount
            } else {
                result
            }
        }
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

        var categories: [CategoryAnalytics] = []

        for category in rawCategories {
            var lastTransactionDate = Date(timeIntervalSince1970: 0)
            let categorySum = rows.filter { $0.category.id == category.id }.reduce(into: Decimal(0)) { result, row in
                result += row.amount
                lastTransactionDate = max(lastTransactionDate, row.transactionDate)
            }
            if categorySum > 0 {
                categories.append(CategoryAnalytics(category, totalValue: categorySum, percentage: categorySum / total, lastTransactionDate: lastTransactionDate ))
            }
        }
        categoryRows = categories
    }

    private func reloadData() {
        Task {
            await loadTransactions()
            categoryRows.sort(by: sortCategories)
            onReloadData?()
        }
    }

    @objc func startDateChanged(_ sender: UIDatePicker) {
        let pickedStart = sender.date.startOfDay
        dayStart = pickedStart
        if dayEnd < dayStart {
            dayEnd = pickedStart.endOfDay
            setEndDateForPicker?(dayEnd)
        }
        reloadData()
    }

    @objc func endDateChanged(_ sender: UIDatePicker) {
        let pickedEnd = sender.date.endOfDay
        dayEnd = pickedEnd
        if dayEnd < dayStart {
            dayStart = pickedEnd.startOfDay
            setStartDateForPicker?(dayStart)
        }
        reloadData()
    }

    @objc func sortOptionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortOption = .byDate
        case 1:
            sortOption = .byAmount
        default:
            break
        }

        reloadData()
    }

    private func sortCategories(_ lhs: CategoryAnalytics, _ rhs: CategoryAnalytics) -> Bool {
        switch sortOption {
        case .byDate:
            return lhs.lastTransactionDate > rhs.lastTransactionDate
        case .byAmount:
            return lhs.percentage > rhs.percentage
        }
    }
}
