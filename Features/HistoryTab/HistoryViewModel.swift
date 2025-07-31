//
//  HistoryViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var transactionRows: [TransactionFull] = []
    @Published var isLoading = false

    @Published var sortOption: TransactionSortOption = .byDate {
        didSet {
            transactionRows.sort(by: sortTransactions)
        }
    }

    @Published var dayStart: Date
    @Published var dayEnd: Date

    private var rawTransactions: [Transaction] = []
    private var rawCategories: [Category] = []
    private var account: BankAccount?

    private let direction: Direction

    private let transactionsProtocol: TransactionsProtocol
    private let categoriesProtocol: CategoriesProtocol
    private let bankAccountsProtocol: BankAccountsProtocol
    var errorHandler: ErrorHandler

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
        transactionsProtocol: TransactionsProtocol = ServiceFactory.shared.transactionsService,
        categoriesProtocol: CategoriesProtocol = ServiceFactory.shared.categoriesService,
        bankAccountsProtocol: BankAccountsProtocol = ServiceFactory.shared.bankAccountsService,
        errorHandler: ErrorHandler
    ) {
        self.direction = direction
        self.dayStart = startDate
        self.dayEnd = endDate
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        self.errorHandler = errorHandler
    }

    func loadTransactions() async {
        isLoading = true

        do {
            let loadedCategories = try await categoriesProtocol.getCategories()
            self.rawCategories = loadedCategories
        } catch {
            errorHandler.handleError(error, context: "HistoryViewModel.loadTransactions", userMessage: "Не удалось загрузить категории")
            isLoading = false
            return
        }

        do {
            let loadedAccount = try await bankAccountsProtocol.getBankAccount()
            self.account = loadedAccount
        } catch {
            errorHandler.handleError(error, context: "HistoryViewModel.loadTransactions", userMessage: "Не удалось загрузить банковский счет")
            isLoading = false
            return
        }

        guard let accountId = account?.id else {
            errorHandler.handleError(NSError(domain: "HistoryViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account ID available"]), context: "HistoryViewModel.loadTransactions", userMessage: "Не удалось загрузить транзакции")
            isLoading = false
            return
        }

        do {
            print("HistoryViewModel: Loading transactions from \(dayStart) to \(dayEnd)")
            let loadedTransactions = try await transactionsProtocol.getTransactionsInTimeFrame(
                accountId: accountId,
                startDate: dayStart,
                endDate: dayEnd
            )
            print("HistoryViewModel: Loaded \(loadedTransactions.count) transactions")
            self.rawTransactions = loadedTransactions
        } catch {
            errorHandler.handleError(error, context: "HistoryViewModel.loadTransactions", userMessage: "Не удалось загрузить транзакции")
            isLoading = false
            return
        }

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
        isLoading = false
    }

    enum SortOption: String, CaseIterable {
        case byDate = "По дате"
        case byAmount = "По сумме"
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

extension HistoryViewModel {
    var accountPublic: BankAccount? { self.account }
    var currencySymbol: String { account?.currency.symbol ?? "₽" }
}
