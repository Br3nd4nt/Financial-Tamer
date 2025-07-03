//
//  HistoryView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @StateObject private var viewModel: HistoryViewModel
    
    private let direction: Direction
    private let maximumDate: Date
    private let dayLength: DateComponents = DateComponents(day: 1, second: -1)
    
    init(direction: Direction) {
        self.direction = direction
        
        let dayStart: Date = Calendar.current.startOfDay(for: Date())
        let dayEnd: Date = {
            guard let date = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.current.startOfDay(for: Date())) else {
                print("Failed to create a date")
                return Date()
            }
            return date
        }()
        
        maximumDate = dayEnd
        
        _viewModel = StateObject(
            wrappedValue: HistoryViewModel(direction: direction, startDate: dayStart, endDate: dayEnd)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Моя история")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .navigationTitle("Моя история")
                
                List {
                    Section {
                        HStack {
                            Text("Начало")
                            Spacer()
                            DatePicker(selection: $viewModel.dayStart, in: ...maximumDate, displayedComponents: .date) {}
                                .onChange(of: viewModel.dayStart) {
                                    if viewModel.dayEnd < viewModel.dayStart {
                                        guard let date = Calendar.current.date(byAdding: dayLength, to: viewModel.dayStart) else {
                                            print("Failed to create a date")
                                            return
                                        }
                                        viewModel.dayEnd = date
                                    }
                                    Task {
                                        await viewModel.loadTransactions()
                                    }
                                }
                                .background(
                                    Color.activeTab.opacity(0.1)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                )
                        }
                        
                        HStack {
                            Text("Конец")
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
                                    Color.activeTab.opacity(0.1)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                )
                        }
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
                            Text("Сумма")
                            Spacer()
                            Text(viewModel.total.formattedWithSeparator(currencySymbol: "₽"))
                        }
                    }
                    Section("Операции") {
                        ForEach(viewModel.transactionRows) { row in
                            HistoryRow(transaction: row.transaction, category: row.category)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {},
                        label: {
                            Image(systemName: "document")
                                .font(.headline)
                                .padding(8)
                        }
                    )
                }
            }
            .task {
                await viewModel.loadTransactions()
            }
        }
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
