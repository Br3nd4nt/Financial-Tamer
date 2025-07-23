//
//  ModelMapper.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

struct ModelMapper {
    static func map(_ dto: BankAccountDTO) -> BankAccount {
        let balance = Decimal(string: dto.balance) ?? Decimal(0)
        let currency = Currency(rawValue: dto.currency) ?? .rub
        return BankAccount(
            id: dto.id,
            userId: dto.id,
            name: dto.name,
            balance: balance,
            currency: currency,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }

    static func map(_ domain: BankAccount) -> BankAccountDTO {
        BankAccountDTO(
            id: domain.id,
            name: domain.name,
            balance: String(describing: domain.balance),
            currency: domain.currency.rawValue,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    static func map(_ dto: CategoryDTO) -> Category {
        let emoji = Character(dto.emoji)
        let direction: Direction = dto.isIncome ? .income : .outcome

        return Category(
            id: dto.id,
            name: dto.name,
            emoji: emoji,
            direction: direction
        )
    }

    static func map(_ domain: Category) -> CategoryDTO {
        CategoryDTO(
            id: domain.id,
            name: domain.name,
            emoji: String(domain.emoji),
            isIncome: domain.direction == .income
        )
    }

    static func map(_ dtos: [BankAccountDTO]) -> [BankAccount] {
        dtos.map { map($0) }
    }

    static func map(_ dtos: [CategoryDTO]) -> [Category] {
        dtos.map { map($0) }
    }

    static func map(_ domains: [BankAccount]) -> [BankAccountDTO] {
        domains.map { map($0) }
    }

    static func map(_ domains: [Category]) -> [CategoryDTO] {
        domains.map { map($0) }
    }

    static func map(_ dto: TransactionDTO) -> Transaction {
        let amount = Decimal(string: dto.amount) ?? Decimal(0)
        let transactionDate = dateFormatter.date(from: dto.transactionDate) ?? Date()
        let createdAt = dateFormatter.date(from: dto.createdAt) ?? Date()
        let updatedAt = dateFormatter.date(from: dto.updatedAt) ?? Date()

        return Transaction(
            id: dto.id,
            accountId: dto.account.id,
            categoryId: dto.category.id,
            amount: amount,
            transactionDate: transactionDate,
            comment: dto.comment ?? "",
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static func map(_ dtos: [TransactionDTO]) -> [Transaction] {
        dtos.map { map($0) }
    }

    static func mapToCreateDTO(_ transaction: Transaction) -> CreateTransactionDTO {
        let amountString = String(format: "%.2f", NSDecimalNumber(decimal: transaction.amount).doubleValue)
        return CreateTransactionDTO(
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: amountString,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment
        )
    }

    static func map(_ dto: CreateTransactionResponseDTO, account: BankAccount, category: Category) -> Transaction {
        let amount = Decimal(string: dto.amount) ?? Decimal(0)
        let transactionDate = dateFormatter.date(from: dto.transactionDate) ?? Date()
        let createdAt = dateFormatter.date(from: dto.createdAt) ?? Date()
        let updatedAt = dateFormatter.date(from: dto.updatedAt) ?? Date()
        return Transaction(
            id: dto.id,
            accountId: dto.accountId,
            categoryId: dto.categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: dto.comment ?? "",
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static func mapToUpdateDTO(_ transaction: Transaction) -> UpdateTransactionDTO {
        let amountString = String(format: "%.2f", NSDecimalNumber(decimal: transaction.amount).doubleValue)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return UpdateTransactionDTO(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: amountString,
            transactionDate: isoFormatter.string(from: transaction.transactionDate),
            comment: transaction.comment,
            createdAt: isoFormatter.string(from: transaction.createdAt),
            updatedAt: isoFormatter.string(from: transaction.updatedAt)
        )
    }
}
