//
//  TransactionsListView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel: TransactionsListViewModel

    @State private var showHistoryView = false
    @State private var selectedTransaction: TransactionFull?
    @State private var showCreateTransaction = false

    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: TransactionsListViewModel(direction: direction)
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
            Text(viewModel.total.formattedWithSeparator(currencySymbol: Constants.currencySymbol))
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
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction: transaction)
        }
        .fullScreenCover(isPresented: $showCreateTransaction, onDismiss: {
            Task { await viewModel.loadTransactions() }
        }) {
            TransactionEditView()
        }
        .overlay(
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
        )
    }

    var body: some View {
        NavigationStack {
            content
            .navigationTitle(direction == .income ? Constants.incomeToday : Constants.outcomeToday)
            .toolbar {
                showHistoryButton
            }
            .navigationDestination(isPresented: $showHistoryView) {
                HistoryView(direction: direction)
            }
        }
        .task {
            await viewModel.loadTransactions()
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
