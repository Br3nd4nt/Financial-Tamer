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
    private let direction: Direction?

    var canSave: Bool {
        category != nil && amount > 0
    }

    init(
        transaction: TransactionFull? = nil,
        direction: Direction? = nil,
        categoriesProtocol: CategoriesProtocol = CategoriesServiceMock.shared,
        bankAccountsProtocol: BankAccountsProtocol = BankAccountsServiceMock.shared
    ) {
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
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
        if let direction {
            loadedCategories = (try? await categoriesProtocol.getCategoriesDyDirection(direction: direction)) ?? []
        } else {
            loadedCategories = (try? await categoriesProtocol.getCategories()) ?? []
        }
        if loadedCategories.isEmpty {
            print("Failed to load categories")
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
            guard let old = editingTransaction, let account = try? await bankAccountsProtocol.getBankAccount(
                userId: 1
            ) else {
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
            _ = try? await TransactionsServiceMock.shared.updateTransaction(transaction: updatedTransaction)
        } else {
            guard let account = try? await bankAccountsProtocol.getBankAccount(
                userId: 1
            ) else {
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
            _ = try? await TransactionsServiceMock.shared.createTransaction(transaction: newTransaction)
            self.category = nil
            self.amount = 0
            self.amountString = ""
            self.date = Date()
            self.comment = ""
        }
    }

    func deleteTransaction() async {
        guard let old = editingTransaction else {
            return
        }
        _ = try? await TransactionsServiceMock.shared.deleteTransaction(id: old.id)
    }
}
