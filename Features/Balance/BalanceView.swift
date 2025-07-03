//
//  BalanceView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import SwiftUI
import UIKit

// i removed background color for rows because they look ugly...
struct BalanceView: View {
    @StateObject private var viewModel = BalanceViewModel()
    @State private var showCurrencyMenu = false
    @FocusState private var isBalanceFieldFocused: Bool
    @State private var balanceInput = Constants.empty
    @State private var editedCurrency: Currency?
    @State private var initialBalance: String = Constants.empty
    @State private var initialCurrency: Currency?

    @State private var spoilerIsOn = true

    private var balanceRow: some View {
        HStack {
            Text(Constants.moneyBagSymbol)
            Text(Constants.balanceTitle)
            Spacer()
            if let account = viewModel.account {
                ZStack {
                    if viewModel.state == .redacting {
                        TextField(Constants.balanceTitle, text: $balanceInput)
                            .keyboardType(.decimalPad)
                            .focused($isBalanceFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                // Set up editing state
                                let formatted = String(describing: account.balance)
                                balanceInput = formatted
                                initialBalance = formatted
                                editedCurrency = account.currency
                                initialCurrency = account.currency
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.balanceFieldFocusDelay) {
                                    isBalanceFieldFocused = true
                                }
                            }
                            .onChange(of: balanceInput) { _, newValue in
                                // Filter input, but do not update model
                                var filtered = newValue.replacingOccurrences(of: Constants.comma, with: Constants.dot)
                                filtered = filtered.filter { Constants.decimalCharacters.contains($0) }
                                if let firstDotIndex = filtered.firstIndex(of: Constants.dot.first!) {
                                    let beforeDot = filtered[..<filtered.index(after: firstDotIndex)]
                                    let afterDot = filtered[filtered.index(after: firstDotIndex)...].replacingOccurrences(of: Constants.dot, with: Constants.empty)
                                    filtered = String(beforeDot) + afterDot
                                }
                                if filtered != newValue {
                                    balanceInput = filtered
                                }
                            }
                            .transition(.opacity)
                    } else {
                        Text(account.balance.formattedWithSeparator(currencySymbol: account.currency.symbol))
                            .spoiler(isOn: $spoilerIsOn)
                            .transition(.opacity)
                    }
                }
                .animation(.default, value: viewModel.state)
            } else {
                ProgressView(Constants.loading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.state == .redacting {
                isBalanceFieldFocused = true
            }
        }
//        .listRowBackground(viewModel.state == .viewing ? .activeTab : Color(.systemBackground))
        .animation(.default, value: viewModel.state)
    }

    private var currencyRow: some View {
        HStack {
            Text(Constants.currencyTitle)
            Spacer()
            if let account = viewModel.account {
                Text((editedCurrency ?? account.currency).symbol)
                if viewModel.state == .redacting {
                    Image(systemName: Constants.chevronRight)
                        .font(.system(size: Constants.chevronFontSize))
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
            } else {
                ProgressView(Constants.loading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.state == .redacting {
                showCurrencyMenu = true
            }
        }
//        .listRowBackground(viewModel.state == .viewing ? .categoryBackground : Color(.systemBackground))
        .animation(.default, value: viewModel.state)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                List {
                    Section {
                        balanceRow
                    }
                    Section {
                        currencyRow
                    }
                }
                .listStyle(.insetGrouped)
                .simultaneousGesture(
                    DragGesture(minimumDistance: Constants.dragMinimumDistance, coordinateSpace: .local)
                        .onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width) {
                                isBalanceFieldFocused = false
                            }
                        }
                )
                .refreshable {
                    if viewModel.state == .viewing {
                        await viewModel.refreshAccount()
                    }
                }
            }
            .confirmationDialog(Constants.currencyTitle, isPresented: $showCurrencyMenu, titleVisibility: .visible) {
                ForEach(Currency.allCases) { option in
                    Button(option.displayName) {
                        editedCurrency = option
                    }
                }
            }
            .navigationTitle(Constants.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            withAnimation {
                                viewModel.toggleState()
                            }
                            if viewModel.state == .viewing {
                                isBalanceFieldFocused = false
                            }
                        },
                        label: {
                            Text(viewModel.state == .viewing ? Constants.editButton : Constants.saveButton)
                        }
                    )
                }
            }
            .task {
                await viewModel.loadAccount()
            }
            .onChange(of: viewModel.state) { _, newState in
                if newState == .redacting, let account = viewModel.account {
                    let formatted = String(describing: account.balance)
                    balanceInput = formatted
                    initialBalance = formatted
                    editedCurrency = account.currency
                    initialCurrency = account.currency
                }
                if newState == .viewing {
                    isBalanceFieldFocused = false
                    if viewModel.account != nil {
                        if balanceInput != initialBalance, let newDecimal = Decimal(string: balanceInput) {
                            Task { await viewModel.updateBalance(newDecimal) }
                        }
                        if let edited = editedCurrency, edited != initialCurrency {
                            Task { await viewModel.updateCurrency(edited) }
                        }
                    }
                }
            }
            .onShake {
                spoilerIsOn.toggle()
            }
        }
    }

    private enum Constants {
        static let title = "Мой счёт"
        static let vStackSpacing: Double = 16
        static let balanceTitle = "Баланс"
        static let moneyBagSymbol = "💰"
        static let currencyTitle = "Валюта"
        static let chevronRight = "chevron.right"
        static let chevronFontSize: Double = 13
        static let editButton = "Редактировать"
        static let saveButton = "Сохранить"
        static let dragMinimumDistance: Double = 20
        static let balanceFieldFocusDelay = 0.1
        static let decimalCharacters = "0123456789."
        static let comma = ","
        static let dot = "."
        static let empty = ""
        static let loading = "Загрузка..."
    }
}

#Preview {
    BalanceView()
}
