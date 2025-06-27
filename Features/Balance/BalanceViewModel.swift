//
//  BalanceViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 27.06.2025.
//

import SwiftUI
import Foundation

class BalanceViewModel: ObservableObject {
    enum State {
        case viewing
        case redacting
    }
    
    @Published var account: BankAccount?
    @Published var state: State = .viewing
    
    private let bankAccountsService: BankAccountsProtocol
    private let userId: Int = 1 // For now, static user id
    
    init(bankAccountsService: BankAccountsProtocol = BankAccountsServiceMock()) {
        self.bankAccountsService = bankAccountsService
    }
    
    @MainActor
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
}
