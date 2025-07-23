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
                categoryPicker
                amountField
                dateField
                timeField
                commentField
                if viewModel.isEditing {
                    deleteSection
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Constants.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? Constants.save : Constants.create) {
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
        .alert(Constants.fillAllFields, isPresented: $showAlert) {
            Button(Constants.ok, role: .cancel) { }
        }
        .onAppear {
            viewModel.onError = { [errorHandler] error, context, userMessage in
                errorHandler.handleError(error, context: context, userMessage: userMessage)
            }
        }
        .errorAlert(errorHandler: errorHandler)
    }

    private var categoryPicker: some View {
        Picker(Constants.categoryPickerTitle, selection: $viewModel.category) {
            if viewModel.category == nil {
                Text(Constants.categoryPickerPlaceholder).tag(nil as Category?)
            }
            ForEach(viewModel.categories) { category in
                Text("\(category.emoji) \(category.name)").tag(category as Category?)
            }
        }
    }

    private var amountField: some View {
        HStack {
            Text(Constants.amountTitle)
            Spacer()
            TextField(Constants.amountPlaceholder, text: $viewModel.amountString)
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
    }

    private var dateField: some View {
        HStack {
            Text(Constants.dateTitle)
            Spacer()
            DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }

    private var timeField: some View {
        HStack {
            Text(Constants.timeTitle)
            Spacer()
            DatePicker("", selection: $viewModel.date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }

    private var commentField: some View {
        ZStack(alignment: .leading) {
            if viewModel.comment.isEmpty {
                Text(Constants.commentPlaceholder)
                    .foregroundColor(Constants.commentPlaceholderColor)
                    .padding(.leading, Constants.commentPlaceholderPadding)
            }
            TextField("", text: $viewModel.comment)
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteTransaction()
                    dismiss()
                }
            } label: {
                Text(Constants.deleteExpense)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private enum Constants {
        static let categoryPickerTitle = "Статья"
        static let categoryPickerPlaceholder = "Выберите категорию"
        static let amountTitle = "Сумма"
        static let amountPlaceholder = "0"
        static let dateTitle = "Дата"
        static let timeTitle = "Время"
        static let commentPlaceholder = "Комментарий"
        static let commentPlaceholderColor = Color.gray
        static let commentPlaceholderPadding: Double = 4
        static let deleteExpense = "Удалить расход"
        static let cancel = "Отменить"
        static let save = "Сохранить"
        static let create = "Создать"
        static let fillAllFields = "Пожалуйста, заполните все поля"
        static let ok = "OK"
    }
}

#Preview {
    TransactionEditView()
}
