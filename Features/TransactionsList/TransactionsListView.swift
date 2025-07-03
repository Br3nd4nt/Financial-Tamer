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

    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: TransactionsListViewModel(direction: direction)
        )
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                Text(direction == .income ? Constants.incomeToday : Constants.outcomeToday)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                List {
                    Section {
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
                        HStack {
                            Text(Constants.totalTitle)
                            Spacer()
                            Text(viewModel.total.formattedWithSeparator(currencySymbol: Constants.currencySymbol))
                        }
                    }
                    Section(Constants.operationsTitle) {
                        ForEach(viewModel.transactionRows) { row in
                            TransactionRow(fullTransaction: row)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
