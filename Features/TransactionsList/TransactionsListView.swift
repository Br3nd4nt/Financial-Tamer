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
            VStack(alignment: .leading, spacing: 16) {
                Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                List {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Выберите метод сортировки")
                                .font(.callout)
                            Picker("Выберите метод сортировки", selection: $viewModel.sortOption) {
                                ForEach(TransactionSortOption.allCases, id: \.self) {
                                    Text("\($0.rawValue)")
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        HStack {
                            Text("Всего")
                            Spacer()
                            Text(viewModel.total.formattedWithSeparator(currencySymbol: "₽"))
                        }
                    }
                    Section("Операции") {
                        ForEach(viewModel.transactionRows) { row in
                            TransactionRow(transaction: row.transaction, category: row.category)
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
                            Image(systemName: "clock")
                                .font(.headline)
                                .padding(8)
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
}

#Preview {
    TransactionsListView(direction: .outcome)
}
