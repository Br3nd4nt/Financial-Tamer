//
//  HistoryView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel
    @StateObject private var errorHandler = ErrorHandler()

    @State private var showAnalytics = false
    @State private var selectedTransaction: TransactionFull?

    private let direction: Direction
    private let maximumDate: Date
    private let dayLength = DateComponents(day: Constants.dayLengthDay, second: Constants.dayLengthSecond)

    init(direction: Direction) {
        self.direction = direction
        let dayStart: Date = Calendar.current.startOfDay(for: Date())
        let dayEnd: Date = {
            guard let date = Calendar.current.date(byAdding: DateComponents(day: Constants.dayLengthDay, second: Constants.dayLengthSecond), to: Calendar.current.startOfDay(for: Date())) else {
                print(Constants.failedToCreateDate)
                return Date()
            }
            return date
        }()
        maximumDate = dayEnd
        _viewModel = StateObject(
            wrappedValue: HistoryViewModel(
                direction: direction,
                startDate: dayStart,
                endDate: dayEnd,
                errorHandler: ErrorHandler()
            )
        )
    }

    private var startDatePicker: some View {
        HStack {
            Text(Constants.startTitle)
            Spacer()
            DatePicker(selection: $viewModel.dayStart, in: ...maximumDate, displayedComponents: .date) {}
                .onChange(of: viewModel.dayStart) {
                    if viewModel.dayEnd < viewModel.dayStart {
                        guard let date = Calendar.current.date(byAdding: dayLength, to: viewModel.dayStart) else {
                            print(Constants.failedToCreateDate)
                            return
                        }
                        viewModel.dayEnd = date
                    }
                    Task {
                        await viewModel.loadTransactions()
                    }
                }
                .background(
                    Color.activeTab.opacity(Constants.datePickerOpacity)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.datePickerCornerRadius))
                )
        }
    }

    private var endDatePicker: some View {
        HStack {
            Text(Constants.endTitle)
            Spacer()
            DatePicker(selection: $viewModel.dayEnd, in: ...maximumDate, displayedComponents: .date) {}
                .onChange(of: viewModel.dayEnd) {
                    if viewModel.dayEnd < viewModel.dayStart {
                        viewModel.dayStart = Calendar.current.startOfDay(for: viewModel.dayEnd)
                    }
                    Task {
                        await viewModel.loadTransactions()
                    }
                }
                .background(
                    Color.activeTab.opacity(Constants.datePickerOpacity)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.datePickerCornerRadius))
                )
        }
    }

    private var sortPicker: some View {
        VStack(alignment: .leading) {
            Text(Constants.sortTitle)
                .font(.callout)
            Picker(Constants.sortTitle, selection: $viewModel.sortOption) {
                ForEach(TransactionSortOption.allCases, id: \.self) {
                    Text("\($0.rawValue)")
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
            List {
                Section {
                    startDatePicker
                    endDatePicker
                    sortPicker
                    HStack {
                        Text(Constants.totalTitle)
                        Spacer()
                        Text(viewModel.total.formattedWithSeparator(currencySymbol: Constants.currencySymbol))
                    }
                }
                Section(Constants.operationsTitle) {
                    if viewModel.transactionRows.isEmpty {
                        Text("Нет транзакций")
                    } else {
                        ForEach(viewModel.transactionRows) { row in
                            HistoryRow(fullTransaction: row)
                                .onTapGesture {
                                    selectedTransaction = row
                                }
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction: transaction)
        }
        .navigationTitle(Constants.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        showAnalytics = true
                    },
                    label: {
                        Image(systemName: Constants.toolbarIcon)
                            .font(.headline)
                            .padding(Constants.toolbarIconPadding)
                    }
                )
            }
        }
        .task {
            await viewModel.loadTransactions()
        }
        .refreshable {
            await viewModel.loadTransactions()
        }
        .errorAlert(errorHandler: errorHandler)
        .navigationDestination(isPresented: $showAnalytics) {
            AnalyticsViewControllerWrapper(direction)
                .navigationTitle("Анализ")
                .ignoresSafeArea(.all)
        }
        .onAppear {
            viewModel.errorHandler = errorHandler
        }
    }

    private enum Constants {
        static let title = "Моя история"
        static let vStackSpacing: Double = 16
        static let startTitle = "Начало"
        static let endTitle = "Конец"
        static let sortTitle = "Выберите метод сортировки"
        static let totalTitle = "Сумма"
        static let operationsTitle = "Операции"
        static let currencySymbol = "₽"
        static let dayLengthDay = 1
        static let dayLengthSecond = -1
        static let failedToCreateDate = "Failed to create a date"
        static let datePickerOpacity = 0.1
        static let datePickerCornerRadius: Double = 10
        static let toolbarIcon = "document"
        static let toolbarIconPadding: Double = 8
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
