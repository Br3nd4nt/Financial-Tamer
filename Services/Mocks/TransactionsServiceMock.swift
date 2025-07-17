//
//  Untitled.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class TransactionsServiceMock: TransactionsProtocol {
    static let shared = TransactionsServiceMock()
    private init() {}
    private var mockTransactions: [Transaction] = [
        // 💸 Зарплата (income)
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 1,
            amount: 180_000,
            transactionDate: .create(day: 10, month: 6, year: 2025),
            comment: "Основная зарплата",
            createdAt: .create(day: 10, month: 6, year: 2025, hour: 9),
            updatedAt: .create(day: 10, month: 6, year: 2025, hour: 9)
        ),

        // 🤑 Подработка (income)
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 2,
            amount: 35_500,
            transactionDate: .create(day: 18, month: 6, year: 2025, hour: 15),
            comment: "Фриланс проект",
            createdAt: .create(day: 18, month: 6, year: 2025, hour: 15),
            updatedAt: .create(day: 18, month: 6, year: 2025, hour: 15)
        ),
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 2,
            amount: 12_000,
            transactionDate: .create(day: 25, month: 6, year: 2025, hour: 10, minute: 30),
            comment: "Консультация",
            createdAt: .create(day: 25, month: 6, year: 2025, hour: 10, minute: 30),
            updatedAt: .create(day: 25, month: 6, year: 2025, hour: 10, minute: 30)
        ),

        // 🏠 Аренда квартиры (outcome)
        Transaction(
            id: 4,
            accountId: 1,
            categoryId: 3,
            amount: 75_000,
            transactionDate: .create(day: 1, month: 7, year: 2025),
            comment: "Аренда за июль",
            createdAt: .create(day: 1, month: 7, year: 2025, hour: 8),
            updatedAt: .create(day: 1, month: 7, year: 2025, hour: 8)
        ),

        // 👔 Одежда (outcome)
        Transaction(
            id: 5,
            accountId: 1,
            categoryId: 4,
            amount: 8500,
            transactionDate: .create(day: 19, month: 6, year: 2025, hour: 16),
            comment: "Куртка",
            createdAt: .create(day: 19, month: 6, year: 2025, hour: 16),
            updatedAt: .create(day: 19, month: 6, year: 2025, hour: 16)
        ),
        Transaction(
            id: 6,
            accountId: 1,
            categoryId: 4,
            amount: 4200,
            transactionDate: .create(day: 2, month: 7, year: 2025, hour: 14, minute: 15),
            comment: "Футболки",
            createdAt: .create(day: 2, month: 7, year: 2025, hour: 14, minute: 15),
            updatedAt: .create(day: 2, month: 7, year: 2025, hour: 14, minute: 15)
        ),

        // 🐕 Питомцы (outcome)
        Transaction(
            id: 7,
            accountId: 1,
            categoryId: 5,
            amount: 3800,
            transactionDate: .create(day: 5, month: 7, year: 2025, hour: 11),
            comment: "Корм для Джека",
            createdAt: .create(day: 5, month: 7, year: 2025, hour: 11),
            updatedAt: .create(day: 5, month: 7, year: 2025, hour: 11)
        ),
        Transaction(
            id: 8,
            accountId: 1,
            categoryId: 5,
            amount: 2500,
            transactionDate: .create(day: 8, month: 7, year: 2025, hour: 9),
            comment: "Игрушка для питомца",
            createdAt: .create(day: 8, month: 7, year: 2025, hour: 9),
            updatedAt: .create(day: 8, month: 7, year: 2025, hour: 9)
        ),

        // 😷 Медицина (outcome)
        Transaction(
            id: 9,
            accountId: 1,
            categoryId: 6,
            amount: 5000,
            transactionDate: .create(day: 10, month: 7, year: 2025, hour: 17, minute: 45),
            comment: "Прием у терапевта",
            createdAt: .create(day: 10, month: 7, year: 2025, hour: 17, minute: 45),
            updatedAt: .create(day: 10, month: 7, year: 2025, hour: 17, minute: 45)
        ),

        // 🏎️ Машина (outcome)
        Transaction(
            id: 10,
            accountId: 1,
            categoryId: 7,
            amount: 15_000,
            transactionDate: .create(day: 11, month: 7, year: 2025, hour: 8),
            comment: "Заправка бензина",
            createdAt: .create(day: 11, month: 7, year: 2025, hour: 8),
            updatedAt: .create(day: 11, month: 7, year: 2025, hour: 8)
        ),
        Transaction(
            id: 11,
            accountId: 1,
            categoryId: 7,
            amount: 7300,
            transactionDate: .create(day: 12, month: 7, year: 2025, hour: 13),
            comment: "Мойка автомобиля",
            createdAt: .create(day: 12, month: 7, year: 2025, hour: 13),
            updatedAt: .create(day: 12, month: 7, year: 2025, hour: 13)
        ),

        Transaction( // Для демонстрации таба дохода
            id: 12,
            accountId: 1,
            categoryId: 1,
            amount: 180_000,
            transactionDate: .create(day: 12, month: 7, year: 2025, hour: 10),
            comment: "Ещё одна зарплата",
            createdAt: .create(day: 12, month: 7, year: 2025, hour: 10),
            updatedAt: .create(day: 12, month: 7, year: 2025, hour: 10)
        )
    ]

    func getTransactionsInTimeFrame(userId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        mockTransactions.filter { $0.accountId == userId && $0.transactionDate >= startDate && $0.transactionDate <= endDate }
    }

    func createTransaction(transaction: Transaction) async throws -> Transaction {
        guard !mockTransactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.dublicatedTransaction
        }

        mockTransactions.append(transaction)
        return transaction
    }

    func updateTransaction(transaction: Transaction) async throws -> Transaction {
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.invalidTransaction
        }

        mockTransactions[index] = transaction

        return transaction
    }

    func deleteTransaction(id: Int) async throws {
        guard let index = mockTransactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionServiceError.invalidTransactionId
        }
        mockTransactions.remove(at: index)
    }
}

extension Date {
    static func create(day: Int, month: Int, year: Int, hour: Int = 12, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
}
