//
//  TransactionEditView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 12.07.2025.
//

import SwiftUI

struct TransactionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TransactionEditViewModel

    init(transaction: TransactionFull? = nil) {
        _viewModel = StateObject(wrappedValue: TransactionEditViewModel(transaction: transaction))
    }

    var body: some View {
        NavigationView {
            List {
                Picker("Статья", selection: $viewModel.category) {
                    if viewModel.category == nil {
                        Text("Выберите категорию").tag(nil as Category?)
                    }
                    ForEach(viewModel.categories) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("0", value: $viewModel.amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Дата")
                    Spacer()
                    DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                HStack {
                    Text("Время")
                    Spacer()
                    DatePicker("", selection: $viewModel.date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                ZStack(alignment: .leading) {
                    if viewModel.comment.isEmpty {
                        Text("Комментарий")
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                    }
                    TextField("", text: $viewModel.comment)
                }
                if viewModel.isEditing {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteTransaction()
                                dismiss()
                            }
                        } label: {
                            Text("Удалить расход")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Сохранить" : "Создать") {
                        Task {
                            await viewModel.saveTransaction()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .task {
            await viewModel.fetchCategories()
        }
    }
}

#Preview {
    let category = Category(id: 1, name: "Wage", emoji: "💸", direction: .income)
    let transaction = Transaction(
        id: 1,
        accountId: 1,
        categoryId: 1,
        amount: 1_000_000,
        transactionDate: Date.now,
        comment: "first transaction",
        createdAt: Date.now,
        updatedAt: Date.now
    )
    let mockAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "My account",
        balance: 10_000,
        currency: .rub,
        createdAt: Date.now,
        updatedAt: Date.now
    )
    let full = TransactionFull(transaction: transaction, account: mockAccount, category: category)
    return TransactionEditView(transaction: full)
}
