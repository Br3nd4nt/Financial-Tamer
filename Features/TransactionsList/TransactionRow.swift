//
//  TransactionRow.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    var fullTransaction: TransactionFull

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.categoryBackground)
                    .aspectRatio(Constants.circleAspectRatio, contentMode: .fit)
                Text("\(fullTransaction.category.emoji)")
                    .padding(Constants.emojiPadding)
            }
            .fixedSize(horizontal: true, vertical: true)

            if fullTransaction.comment.isEmpty {
                Text(fullTransaction.category.name)
                    .lineLimit(Constants.lineLimit)
            } else {
                VStack(alignment: .leading) {
                    Text(fullTransaction.category.name)
                        .lineLimit(Constants.lineLimit)
                    Text(fullTransaction.comment)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(Constants.lineLimit)
                }
            }
            Spacer()
            Text(fullTransaction.amount.formattedWithSeparator(currencySymbol: Constants.currencySymbol))

            Image(systemName: Constants.chevronRight)
                .font(.system(size: Constants.chevronFontSize, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, Constants.chevronPadding)
        }
    }

    private enum Constants {
        static let circleAspectRatio: Double = 1
        static let emojiPadding: Double = 6
        static let lineLimit = 1
        static let currencySymbol = "₽"
        static let chevronRight = "chevron.right"
        static let chevronFontSize: Double = 13
        static let chevronPadding: Double = 8
    }
}

#Preview {
    struct PreviewWrapper: View {
        private var categories: [Category] = [
            Category(id: 1, name: "Wage", emoji: "💸", direction: .income),
            Category(id: 2, name: "Clothes", emoji: "👔", direction: .outcome),
            Category(id: 3, name: "Pets", emoji: "🐶", direction: .outcome)
        ]
        private var transactions: [Transaction] = [
            Transaction(
                id: 1,
                accountId: 1,
                categoryId: 1,
                amount: 100,
                transactionDate: Date.now,
                comment: "first transaction",
                createdAt: Date.now,
                updatedAt: Date.now
            ),
            Transaction(
                id: 2,
                accountId: 1,
                categoryId: 2,
                amount: 200,
                transactionDate: Date.now,
                comment: "second transaction",
                createdAt: Date.now,
                updatedAt: Date.now
            ),
            Transaction(
                id: 3,
                accountId: 1,
                categoryId: 3,
                amount: 3000,
                transactionDate: Date.now,
                comment: "",
                createdAt: Date.now,
                updatedAt: Date.now
            )
        ]
        private var mockAccount = BankAccount(
            id: 1,
            userId: 1,
            name: "My account",
            balance: 10_000,
            currency: .rub,
            createdAt: Date.now,
            updatedAt: Date.now
        )

        var body: some View {
            List {
                ForEach(Array(transactions.enumerated()), id: \ .element.id) { _, transaction in
                    let category = categories.first { $0.id == transaction.categoryId }

                    Group {
                        if let category {
                            let full = TransactionFull(transaction: transaction, account: mockAccount, category: category)
                            TransactionRow(fullTransaction: full)
                        } else {
                            HStack {
                                Text("Категория не найдена")
                                Spacer()
                                Text("ID: \(transaction.categoryId)")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }

    return PreviewWrapper()
}
