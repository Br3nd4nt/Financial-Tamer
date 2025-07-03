//
//  BalanceViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import SwiftUI
import Foundation

@MainActor
final class BalanceViewModel: ObservableObject {
    enum State {
        case viewing
        case redacting
    }

    @Published var account: BankAccount?
    @Published var state: State = .viewing

    private let bankAccountsService: BankAccountsProtocol
    private let userId = 1

    init(bankAccountsService: BankAccountsProtocol = BankAccountsServiceMock.shared) {
        self.bankAccountsService = bankAccountsService
    }

    func loadAccount() async {
        do {
            let account = try await bankAccountsService.getBankAccount(userId: userId)
            self.account = account
        } catch {
            print("Failed to load bank account: \(error)")
            self.account = nil
        }
    }

    func setState(_ newState: State) {
        state = newState
    }

    func toggleState() {
        state = (state == .viewing) ? .redacting : .viewing
    }

    func refreshAccount() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // just simulation of waiting for server response
        await loadAccount()
    }

    func updateAccount(_ updated: BankAccount) async {
        do {
            let newAccount = try await bankAccountsService.updateBankAccount(userId: userId, newAccount: updated)
            self.account = newAccount
        } catch {
            print("Failed to update bank account: \(error)")
        }
    }

    func updateBalance(_ newBalance: Decimal) async {
        guard var current = account else {
            return
        }
        current = BankAccount(
            id: current.id,
            userId: current.userId,
            name: current.name,
            balance: newBalance,
            currency: current.currency,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
        await updateAccount(current)
    }

    func updateCurrency(_ newCurrency: Currency) async {
        guard var current = account else {
            return
        }
        current = BankAccount(
            id: current.id,
            userId: current.userId,
            name: current.name,
            balance: current.balance,
            currency: newCurrency,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
        await updateAccount(current)
    }
}
