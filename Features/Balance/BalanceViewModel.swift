//
//  BalanceViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import Foundation

@MainActor
final class BalanceViewModel: ObservableObject {
    enum State {
        case viewing
        case redacting
    }

    @Published var account: BankAccount?
    @Published var state: State = .viewing
    @Published var isLoading = false

    private var userId: Int?
    private let bankAccountsService: BankAccountsProtocol
    var errorHandler: ErrorHandler

    init(bankAccountsService: BankAccountsProtocol = ServiceFactory.shared.bankAccountsService, errorHandler: ErrorHandler) {
        self.bankAccountsService = bankAccountsService
        self.errorHandler = errorHandler
    }

    func loadAccount() async {
        isLoading = true

        do {
            let loadedAccount = try await bankAccountsService.getBankAccount()
            self.account = loadedAccount
            self.userId = loadedAccount.userId
        } catch {
            errorHandler.handleError(error, context: "BalanceViewModel.loadAccount", userMessage: "Не удалось загрузить банковский счет")
            isLoading = false
            return
        }

        isLoading = false
    }

    func setState(_ newState: State) {
        state = newState
    }

    func toggleState() {
        state = (state == .viewing) ? .redacting : .viewing
    }

    func refreshAccount() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await loadAccount()
    }

    func updateBalance(_ newBalance: Decimal) async {
        guard var current = account else {
            errorHandler.handleError(NSError(domain: "BalanceViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account to update"]), context: "BalanceViewModel.updateBalance", userMessage: "Нет счета для обновления")
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
            errorHandler.handleError(NSError(domain: "BalanceViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account to update"]), context: "BalanceViewModel.updateCurrency", userMessage: "Нет счета для обновления")
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

    func updateAccount(_ updated: BankAccount) async {
        guard let userId else {
            errorHandler.handleError(NSError(domain: "BalanceViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user ID available"]), context: "BalanceViewModel.updateAccount", userMessage: "Не удалось обновить банковский счет")
            return
        }

        do {
            let newAccount = try await bankAccountsService.updateBankAccount(userId: userId, newAccount: updated)
            self.account = newAccount
        } catch {
            errorHandler.handleError(error, context: "BalanceViewModel.updateAccount", userMessage: "Не удалось обновить банковский счет")
        }
    }
}
