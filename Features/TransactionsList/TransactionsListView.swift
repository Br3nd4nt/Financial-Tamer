//
//  TransactionsListView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel: TransactionsListViewModel
    @StateObject private var errorHandler = ErrorHandler()

    @State private var showHistoryView = false
    @State private var selectedTransaction: TransactionFull?
    @State private var showCreateTransaction = false
    @State private var showClearBackupAlert = false

    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: TransactionsListViewModel(
                direction: direction,
                errorHandler: ErrorHandler()
            )
        )
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

    private var showHistoryButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(
                action: {
                    showHistoryView = true
                },
                label: {
                    Image(systemName: Constants.toolbarIcon)
                        .font(.headline)
                        .padding(Constants.toolbarIconPadding)
                }
            )
        }
    }

    private var total: some View {
        HStack {
            Text(Constants.totalTitle)
            Spacer()
            Text(viewModel.total.formattedWithSeparator(currencySymbol: viewModel.currencySymbol))
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
            List {
                Section {
                    sortPicker
                    total
                }
                Section(Constants.operationsTitle) {
                    ForEach(viewModel.transactionRows) { row in
                        TransactionRow(fullTransaction: row)
                            .onTapGesture {
                                selectedTransaction = row
                            }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))

                        Text("Загрузка транзакций...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else if viewModel.transactionRows.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("Нет транзакций")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text("Здесь будут отображаться ваши \(direction == .income ? "доходы" : "расходы")")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    content
                }
            }
            .navigationTitle(direction == .income ? Constants.incomeToday : Constants.outcomeToday)
            .toolbar {
                showHistoryButton
            }
            .navigationDestination(isPresented: $showHistoryView) {
                HistoryView(direction: direction)
            }
            .fullScreenCover(item: $selectedTransaction) { transaction in
                TransactionEditView(transaction: transaction)
            }
            .fullScreenCover(isPresented: $showCreateTransaction, onDismiss: {
                Task { await viewModel.loadTransactions() }
            }) {
                TransactionEditView(direction: direction)
            }
            .overlay(
                Group {
                    if !viewModel.isLoading {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { showCreateTransaction = true }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Circle().fill(Color.accentColor))
                                        .shadow(radius: 4)
                                }
                                .padding()
                            }
                        }
                    }
                }
            )
            .refreshable {
                // Does not refresh for some reason
                // It detects two gestures and they cancel each other?..
                await viewModel.loadTransactions()
            }
            .errorAlert(errorHandler: errorHandler)
        }
        .onAppear {
            viewModel.errorHandler = errorHandler
            Task { await viewModel.loadTransactions() }
        }
    }

    private enum Constants {
        static let incomeToday = "Доходы сегодня"
        static let outcomeToday = "Расходы сегодня"
        static let vStackSpacing: Double = 16
        static let sortTitle = "Выберите метод сортировки"
        static let totalTitle = "Всего"
        static let operationsTitle = "Операции"
        static let currencySymbol = "₽"
        static let toolbarIcon = "clock"
        static let toolbarIconPadding: Double = 8
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
