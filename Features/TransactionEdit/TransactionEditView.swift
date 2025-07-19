//
//  TransactionEditView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 12.07.2025.
//

import SwiftUI

struct TransactionEditView: View {
    @StateObject private var viewModel: TransactionEditViewModel
    @StateObject private var errorHandler = ErrorHandler()

    @Environment(\.dismiss) private var dismiss

    init(transaction: TransactionFull? = nil, direction: Direction? = nil) {
        _viewModel = StateObject(wrappedValue: TransactionEditViewModel(
            transaction: transaction,
            direction: direction
        )            { _, _, _ in
                // Will be set in onAppear
        })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Сумма", value: $viewModel.amount, format: .number)
                        .keyboardType(.decimalPad)

                    TextField("Описание", text: $viewModel.comment)
                }

                Section {
                    Picker("Категория", selection: $viewModel.category) {
                        Text("Выберите категорию").tag(nil as Category?)
                        ForEach(viewModel.categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                }

                Section {
                    DatePicker("Дата", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                }
            }
                            .navigationTitle(viewModel.isEditing ? "Редактировать" : "Новая операция")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.saveTransaction()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
            .errorAlert(errorHandler: errorHandler)
        }
        .onAppear {
            viewModel.onError = { [errorHandler] error, context, userMessage in
                errorHandler.handleError(error, context: context, userMessage: userMessage)
            }
        }
    }
}

#Preview {
    TransactionEditView()
}
