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
    @State private var balanceInput: String = ""
    
    @State private var spoilerIsOn = true
    
    private func displayCurrencySymbol(for currency: String) -> String {
        Currency.allCases.first {
            $0.rawValue == currency || $0.symbol == currency
        }?.symbol ?? currency
    }
    
    private var balanceRow: some View {
        HStack {
            Text("Баланс")
            Spacer()
            if let account = viewModel.account {
                ZStack {
                    if viewModel.state == .redacting {
                        TextField("Баланс", text: $balanceInput)
                            .keyboardType(.decimalPad)
                            .focused($isBalanceFieldFocused)
                            .onAppear {
                                balanceInput = String(describing: account.balance)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isBalanceFieldFocused = true
                                }
                            }
                            .onChange(of: balanceInput) { _, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
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
                                    viewModel.account = updated
                                    Task { await viewModel.updateAccount(updated) }
                                }
                            }
                            .transition(.opacity)
                    } else {
                        Text(account.balance.formattedWithSeparator(currencySymbol: displayCurrencySymbol(for: account.currency)))
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
        .listRowBackground(viewModel.state == .viewing ? .activeTab : Color(.systemBackground))
        .animation(.default, value: viewModel.state)
    }
    
    private var currencyRow: some View {
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
                        balanceRow
                    }
                    Section {
                        currencyRow
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
                .refreshable {
                    if viewModel.state == .viewing {
                        await viewModel.refreshAccount()
                    }
                }
            }
            .confirmationDialog("Валюта", isPresented: $showCurrencyMenu, titleVisibility: .visible) {
                ForEach(Currency.allCases, id: \.self) { option in
                    Button(option.displayName) {
                        if var account = viewModel.account {
                            account.currency = option.rawValue
                            Task {await viewModel.updateAccount(account)}
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
                            Text(viewModel.state == .viewing ? "Редактировать" : "Сохранить")
                        }
                    )
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadAccount()
                }
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
}

#Preview {
    BalanceView()
}
