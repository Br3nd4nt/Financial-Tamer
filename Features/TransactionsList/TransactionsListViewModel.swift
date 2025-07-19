//
//  TransactionsListViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import Foundation

@MainActor
final class TransactionsListViewModel: ObservableObject {
    @Published var transactionRows: [TransactionFull] = []
    @Published var isLoading = false
    


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
    var errorHandler: ErrorHandler

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
                result + row.amount
            } else {
                result
            }
        }
    }

    init(
        direction: Direction,
        transactionsProtocol: TransactionsProtocol = ServiceFactory.shared.transactionsService,
        categoriesProtocol: CategoriesProtocol = ServiceFactory.shared.categoriesService,
        bankAccountsProtocol: BankAccountsProtocol = ServiceFactory.shared.bankAccountsService,
        errorHandler: ErrorHandler
    ) {
        self.direction = direction
        self.transactionsProtocol = transactionsProtocol
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        self.errorHandler = errorHandler
    }

    func loadTransactions() async {
        print("Starting loadTransactions...")
        isLoading = true

        do {
            print("Loading categories...")
            let loadedCategories = try await categoriesProtocol.getCategories()
            self.rawCategories = loadedCategories
            print("Categories loaded successfully: \(loadedCategories.count) categories")
        } catch {
            print("Failed to load categories: \(error)")
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Categories request was cancelled during refresh")
                isLoading = false
                return
            }
            errorHandler.handleError(error, context: "TransactionsListViewModel.loadTransactions", userMessage: "Не удалось загрузить категории")
            isLoading = false
            return
        }

        do {
            print("Loading bank account...")
            let loadedAccount = try await bankAccountsProtocol.getBankAccount(userId: 1)
            self.account = loadedAccount
            print("Bank account loaded successfully: \(loadedAccount.id)")
        } catch {
            print("Failed to load bank account: \(error)")
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Bank account request was cancelled during refresh")
                isLoading = false
                return
            }
            errorHandler.handleError(error, context: "TransactionsListViewModel.loadTransactions", userMessage: "Не удалось загрузить банковский счет")
            isLoading = false
            return
        }

        guard let accountId = account?.id else {
            errorHandler.handleError(NSError(domain: "TransactionsListViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account ID available"]), context: "TransactionsListViewModel.loadTransactions", userMessage: "Не удалось загрузить транзакции")
            isLoading = false
            return
        }

        do {
            let loadedTransactions = try await transactionsProtocol.getTransactionsInTimeFrame(
                accountId: accountId,
                startDate: dayStart,
                endDate: dayEnd
            )
            self.rawTransactions = loadedTransactions
        } catch {
            print("Failed to load transactions: \(error)")
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Transactions request was cancelled during refresh")
                isLoading = false
                return
            }
            errorHandler.handleError(error, context: "TransactionsListViewModel.loadTransactions", userMessage: "Не удалось загрузить транзакции")
            isLoading = false
            return
        }

        let categoryDict = Dictionary(grouping: rawCategories, by: { $0.id })
            .compactMapValues { categories in
                categories.first
            }

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

    private func sortTransactions(_ lhs: TransactionFull, _ rhs: TransactionFull) -> Bool {
        switch sortOption {
        case .byDate:
            return lhs.transactionDate > rhs.transactionDate
        case .byAmount:
            return lhs.amount > rhs.amount
        }
    }
}
