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
                    Image(systemName: Constants.Images.clock)
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

    private var loadingView: some View {
        VStack(spacing: Constants.loadingVStackSpacing) {
            ProgressView()
                .scaleEffect(Constants.progressScale)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            Text(Constants.loadingText)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var emptyView: some View {
        VStack(spacing: Constants.emptyVStackSpacing) {
            Image(systemName: Constants.Images.emptyList)
                .font(.system(size: Constants.emptyListIconSize))
                .foregroundColor(.secondary)
            Text(Constants.noTransactionsText)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(direction == .income ? Constants.emptyIncomeText : Constants.emptyOutcomeText)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var floatingPlusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showCreateTransaction = true }) {
                    Image(systemName: Constants.Images.plus)
                        .font(.system(size: Constants.plusIconSize, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.accentColor))
                        .shadow(radius: Constants.plusIconShadowRadius)
                }
                .padding()
            }
        }
    }

    private var mainContent: some View {
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
                    loadingView
                } else if viewModel.transactionRows.isEmpty {
                    emptyView
                } else {
                    mainContent
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
                        floatingPlusButton
                    }
                }
            )
            .refreshable {
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
        static let toolbarIcon = Images.clock
        static let toolbarIconPadding: Double = 8
        static let loadingVStackSpacing: Double = 16
        static let progressScale = 1.5
        static let loadingText = "Загрузка транзакций..."
        static let emptyVStackSpacing: Double = 16
        static let noTransactionsText = "Нет транзакций"
        static let emptyIncomeText = "Здесь будут отображаться ваши доходы"
        static let emptyOutcomeText = "Здесь будут отображаться ваши расходы"
        static let plusIconSize: Double = 28
        static let plusIconShadowRadius: Double = 4
        struct Images {
            static let emptyList = "list.bullet.clipboard"
            static let plus = "plus"
            static let clock = "clock"
        }
        static let emptyListIcon = Images.emptyList
        static let emptyListIconSize: Double = 48
        static let plusIcon = Images.plus
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
