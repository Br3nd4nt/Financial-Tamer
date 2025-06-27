//
//  BalanceView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import SwiftUI

struct BalanceView: View {
    @StateObject private var viewModel = BalanceViewModel()
    @State private var showCurrencyMenu = false
    @FocusState private var isBalanceFieldFocused: Bool
    @State private var balanceInput: String = ""
    
    private let currencyOptions: [(symbol: String, name: String, code: String)] = [
        ("₽", "Российский рубль ₽", "RUB"),
        ("$", "Американский доллар $", "USD"),
        ("€", "Евро €", "EUR")
    ]
    
    private func displayCurrencySymbol(for currency: String) -> String {
        if let found = currencyOptions.first(where: { $0.symbol == currency || $0.code == currency }) {
            return found.symbol
        }
        return currency
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Мой счёт")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                List {
                    Section {
                        HStack {
                            Text("Баланс")
                            Spacer()
                            if let account = viewModel.account {
                                ZStack {
                                    if viewModel.state == .redacting {
                                        TextField("Баланс", text: $balanceInput)
                                            .keyboardType(.decimalPad)
                                            .focused($isBalanceFieldFocused)
                                            .multilineTextAlignment(.trailing)
                                            .onAppear {
                                                balanceInput = String(describing: account.balance)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    isBalanceFieldFocused = true
                                                }
                                            }
                                            .onChange(of: balanceInput) { oldValue, newValue in
                                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                                    .replacingOccurrences(of: " ", with: "")
                                                if let newDecimal = Decimal(string: filtered) {
                                                    let updated = BankAccount(id: account.id, userId: account.userId, name: account.name, balance: newDecimal, currency: account.currency, createdAt: account.createdAt, updatedAt: account.updatedAt)
                                                    viewModel.account = updated
                                                }
                                            }
                                            .transition(.opacity)
                                    } else {
                                        Text(account.balance.formattedWithSeparator(currencySymbol: displayCurrencySymbol(for: account.currency)))
                                            .transition(.opacity)
                                    }
                                }
                                .animation(.default, value: viewModel.state)
                            } else {
                                ProgressView()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.state == .redacting {
                                isBalanceFieldFocused = true
                            }
                        }
                        .listRowBackground(viewModel.state == .viewing ? .activeTab : Color(.systemBackground))
                        .animation(.default, value: viewModel.state)
                    }
                    Section {
                        HStack {
                            Text("Валюта")
                            Spacer()
                            if let account = viewModel.account {
                                Text(displayCurrencySymbol(for: account.currency))
                                if viewModel.state == .redacting {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                        .transition(.opacity)
                                }
                            } else {
                                ProgressView()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.state == .redacting {
                                showCurrencyMenu = true
                            }
                        }
                        .listRowBackground(viewModel.state == .viewing ? .categoryBackground : Color(.systemBackground))
                        .animation(.default, value: viewModel.state)
                    }
                }
                .listStyle(.insetGrouped)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width) {
                                isBalanceFieldFocused = false
                            }
                        }
                )
            }
            .confirmationDialog("Валюта", isPresented: $showCurrencyMenu, titleVisibility: .visible) {
                ForEach(currencyOptions, id: \.symbol) { option in
                    Button(option.name) {
                        if var account = viewModel.account {
                            account = BankAccount(id: account.id, userId: account.userId, name: account.name, balance: account.balance, currency: option.symbol, createdAt: account.createdAt, updatedAt: account.updatedAt)
                            viewModel.account = account
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.toggleState()
                        }
                        if viewModel.state == .viewing {
                            isBalanceFieldFocused = false
                        }
                    }) {
                        Text(viewModel.state == .viewing ? "Редактировать" : "Сохранить")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadAccount()
                }
            }
            .onChange(of: viewModel.state) { oldState, newState in
                if newState == .redacting, let account = viewModel.account {
                    balanceInput = String(describing: account.balance)
                }
                if newState == .viewing {
                    isBalanceFieldFocused = false
                }
            }
        }
    }
}

private extension Decimal {
    func formatted() -> String {
        // Always use dot as decimal separator for editing, no grouping
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = false
        return formatter.string(for: self) ?? ""
    }
}

#Preview {
    BalanceView()
}
