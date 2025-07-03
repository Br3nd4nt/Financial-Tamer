//
//  BalanceView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import SwiftUI
import UIKit

struct BalanceView: View {
    @StateObject private var viewModel = BalanceViewModel()
    @State private var showCurrencyMenu = false
    @FocusState private var isBalanceFieldFocused: Bool
    @State private var balanceInput = ""

    @State private var spoilerIsOn = true

    private var balanceRow: some View {
        HStack {
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
                                balanceInput = String(describing: account.balance)
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.balanceFieldFocusDelay) {
                                    isBalanceFieldFocused = true
                                }
                            }
                            .onChange(of: balanceInput) { _, newValue in
                                let filtered = newValue.filter { Constants.decimalCharacters.contains($0) }
                                if filtered != newValue {
                                    balanceInput = filtered
                                }
                                if let newDecimal = Decimal(string: filtered) {
                                    let updated = BankAccount(
                                        id: account.id,
                                        userId: account.userId,
                                        name: account.name,
                                        balance: newDecimal,
                                        currency: account.currency,
                                        createdAt: account.createdAt,
                                        updatedAt: account.updatedAt
                                    )
                                    Task { await viewModel.updateAccount(updated) }
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
                ProgressView()
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
                Text(account.currency.symbol)
                if viewModel.state == .redacting {
                    Image(systemName: Constants.chevronRight)
                        .font(.system(size: Constants.chevronFontSize))
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
//        .listRowBackground(viewModel.state == .viewing ? .categoryBackground : Color(.systemBackground))
        .animation(.default, value: viewModel.state)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                Text(Constants.title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)

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
                        if var account = viewModel.account {
                            account.currency = option
                            Task { await viewModel.updateAccount(account) }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
                    balanceInput = String(describing: account.balance)
                }
                if newState == .viewing {
                    isBalanceFieldFocused = false
                }
            }
            .onShake {
                spoilerIsOn = false
            }
        }
    }

    private enum Constants {
        static let title = "Мой счёт"
        static let vStackSpacing: Double = 16
        static let balanceTitle = "Баланс"
        static let currencyTitle = "Валюта"
        static let chevronRight = "chevron.right"
        static let chevronFontSize: Double = 13
        static let editButton = "Редактировать"
        static let saveButton = "Сохранить"
        static let dragMinimumDistance: Double = 20
        static let balanceFieldFocusDelay = 0.1
        static let decimalCharacters = "0123456789."
    }
}

#Preview {
    BalanceView()
}
