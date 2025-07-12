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

    private let categoriesProtocol: CategoriesProtocol
    private let bankAccountsProtocol: BankAccountsProtocol
    private var account: BankAccount?

    var canSave: Bool {
        category != nil && amount > 0
    }

    init(
        transaction: TransactionFull? = nil,
        categoriesProtocol: CategoriesProtocol = CategoriesServiceMock.shared,
        bankAccountsProtocol: BankAccountsProtocol = BankAccountsServiceMock.shared
    ) {
        self.categoriesProtocol = categoriesProtocol
        self.bankAccountsProtocol = bankAccountsProtocol
        if let transaction {
            // Editing
            self.isEditing = true
            self.category = transaction.category
            self.amount = transaction.amount
            self.amountString = transaction.amount.formatted()
            self.date = transaction.transactionDate
            self.comment = transaction.comment
        } else {
            // Creating
            self.isEditing = false
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
        guard let loadedCategories = try? await categoriesProtocol.getCategories() else {
            print("Failed to load categories")
            return
        }
        self.categories = loadedCategories
        // Ensure the selected category is from the loaded array
        if let current = self.category {
            self.category = loadedCategories.first { $0.id == current.id }
        }
    }

    func deleteTransaction() async {
    }

    func saveTransaction() async {
        guard let category, amount > 0 else { return }
        if isEditing {
            // обновление существующей транзакции (реализовать при необходимости)
        } else {
            guard let account = try? await bankAccountsProtocol.getBankAccount(userId: 1) else { return }
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
            self.date = Date()
            self.comment = ""
        }
    }
}
