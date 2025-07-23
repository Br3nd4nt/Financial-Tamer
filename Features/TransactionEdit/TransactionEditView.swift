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
    @StateObject private var errorHandler = ErrorHandler()
    @State private var showAlert = false

    init(transaction: TransactionFull? = nil, direction: Direction? = nil) {
        _viewModel = StateObject(wrappedValue: TransactionEditViewModel(transaction: transaction, direction: direction) { _, _, _ in })
    }

    var body: some View {
        NavigationView {
            List {
                Picker("Статья", selection: $viewModel.category) {
                    if viewModel.category == nil {
                        Text("Выберите категорию").tag(nil as Category?)
                    }
                    ForEach(viewModel.categories) { category in
                        Text("\(category.emoji) \(category.name)").tag(category as Category?)
                    }
                }
                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("0", text: $viewModel.amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: viewModel.amountString) { _, newValue in
                            var filtered = newValue.replacingOccurrences(of: ",", with: ".")
                            filtered = filtered.filter { "0123456789.".contains($0) }
                            if let firstDotIndex = filtered.firstIndex(of: ".".first!) {
                                let beforeDot = filtered[..<filtered.index(after: firstDotIndex)]
                                let afterDot = filtered[filtered.index(after: firstDotIndex)...].replacingOccurrences(of: ".", with: "")
                                filtered = String(beforeDot) + afterDot
                            }
                            if filtered != newValue {
                                viewModel.amountString = filtered
                            }
                        }
                }
                HStack {
                    Text("Дата")
                    Spacer()
                    DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
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
                        let separator = Locale.current.decimalSeparator ?? "."
                        let filtered = viewModel.amountString.replacingOccurrences(of: separator, with: ".")
                        if let decimal = Decimal(string: filtered) {
                            viewModel.amount = decimal
                        } else {
                            viewModel.amount = 0
                        }
                        if viewModel.canSave {
                            Task {
                                await viewModel.saveTransaction()
                                dismiss()
                            }
                        } else {
                            showAlert = true
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchCategories()
        }
        .alert("Пожалуйста, заполните все поля", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            viewModel.onError = { [errorHandler] error, context, userMessage in
                errorHandler.handleError(error, context: context, userMessage: userMessage)
            }
        }
        .errorAlert(errorHandler: errorHandler)
    }
}

#Preview {
    TransactionEditView()
}
