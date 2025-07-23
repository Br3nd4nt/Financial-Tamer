//
//  TransactionEditViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 12.07.2025.
//

import SwiftUI

@MainActor
final class TransactionEditViewModel: ObservableObject {
    @Published var category: Category?
    @Published var amount: Decimal = 0
    @Published var date = Date()
    @Published var comment = ""
    @Published var amountString = ""
    @Published var categories: [Category] = []
    @Published var isEditing = false

    private var editingTransaction: TransactionFull?
    private let categoriesProtocol: CategoriesProtocol
    private let bankAccountsProtocol: BankAccountsProtocol
    private let transactionsProtocol: TransactionsProtocol
    var onError: (Error, String, String?) -> Void
    private let direction: Direction?

    var canSave: Bool {
        category != nil && amount > 0
    }

    init(
        transaction: TransactionFull? = nil,
        direction: Direction? = nil,
        categoriesProtocol: CategoriesProtocol = ServiceFactory.shared.categoriesService,
        bankAccountsProtocol: BankAccountsProtocol = ServiceFactory.shared.bankAccountsService,
        transactionsProtocol: TransactionsProtocol = ServiceFactory.shared.transactionsService,
        onError: @escaping (Error, String, String?) -> Void
    ) {
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        self.transactionsProtocol = transactionsProtocol
        self.onError = onError
        self.direction = direction
        if let transaction {
            self.isEditing = true
            self.editingTransaction = transaction
            self.category = transaction.category
            self.amount = transaction.amount
            self.amountString = transaction.amount.formatted()
            self.date = transaction.transactionDate
            self.comment = transaction.comment
        } else {
            self.isEditing = false
            self.editingTransaction = nil
            self.category = nil
            self.amount = 0
            self.amountString = ""
            self.date = Date()
            self.comment = ""
        }
        Task {
            await fetchCategories()
        }
    }

    func fetchCategories() async {
        let loadedCategories: [Category]
        do {
            if let direction {
                loadedCategories = try await categoriesProtocol.getCategoriesDyDirection(direction: direction)
            } else {
                loadedCategories = try await categoriesProtocol.getCategories()
            }
        } catch {
            onError(error, "TransactionEditViewModel.fetchCategories", "Не удалось загрузить категории")
            return
        }

        if loadedCategories.isEmpty {
            onError(NSError(domain: "TransactionEditViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No categories available"]), "TransactionEditViewModel.fetchCategories", "Категории не найдены")
            return
        }

        self.categories = loadedCategories
        if let current = self.category {
            self.category = loadedCategories.first { $0.id == current.id }
        }
    }

    func saveTransaction() async {
        guard let category, amount > 0 else {
            return
        }

        if isEditing {
            guard let old = editingTransaction else {
                onError(NSError(domain: "TransactionEditViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No transaction to edit"]), "TransactionEditViewModel.saveTransaction", "Ошибка редактирования транзакции")
                return
            }

            let account: BankAccount
            do {
                account = try await bankAccountsProtocol.getBankAccount()
            } catch {
                onError(error, "TransactionEditViewModel.saveTransaction", "Не удалось загрузить банковский счет")
                return
            }

            let updatedTransaction = Transaction(
                id: old.id,
                accountId: account.id,
                categoryId: category.id,
                amount: amount,
                transactionDate: date,
                comment: comment,
                createdAt: old.createdAt,
                updatedAt: Date()
            )

            do {
                _ = try await transactionsProtocol.updateTransaction(transaction: updatedTransaction)
                NotificationCenter.default.post(name: .accountBalanceUpdatedNotification, object: nil)
            } catch {
                onError(error, "TransactionEditViewModel.saveTransaction", "Не удалось обновить транзакцию")
                return
            }
        } else {
            let account: BankAccount
            do {
                account = try await bankAccountsProtocol.getBankAccount()
            } catch {
                onError(error, "TransactionEditViewModel.saveTransaction", "Не удалось загрузить банковский счет")
                return
            }

            let newTransaction = Transaction(
                id: Int.random(in: 1000...9999),
                accountId: account.id,
                categoryId: category.id,
                amount: amount,
                transactionDate: date,
                comment: comment,
                createdAt: Date(),
                updatedAt: Date()
            )

            do {
                _ = try await transactionsProtocol.createTransaction(transaction: newTransaction)
                NotificationCenter.default.post(name: .accountBalanceUpdatedNotification, object: nil)
            } catch {
                onError(error, "TransactionEditViewModel.saveTransaction", "Не удалось создать транзакцию")
                return
            }

            self.category = nil
            self.amount = 0
            self.amountString = ""
            self.date = Date()
            self.comment = ""
        }
    }

    func deleteTransaction() async {
        guard let old = editingTransaction else {
            onError(NSError(domain: "TransactionEditViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No transaction to delete"]), "TransactionEditViewModel.deleteTransaction", "Ошибка удаления транзакции")
            return
        }

        do {
            try await transactionsProtocol.deleteTransaction(id: old.id)
            NotificationCenter.default.post(name: .accountBalanceUpdatedNotification, object: nil)
        } catch {
            onError(error, "TransactionEditViewModel.deleteTransaction", "Не удалось удалить транзакцию")
        }
    }
}
