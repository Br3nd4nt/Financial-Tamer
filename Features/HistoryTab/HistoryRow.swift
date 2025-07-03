//
//  HistoryRow.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import SwiftUI

struct HistoryRow: View {
    var transaction: Transaction
    var category: Category

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.categoryBackground)
                    .aspectRatio(Constants.circleAspectRatio, contentMode: .fit)
                Text("\(category.emoji)")
                    .padding(Constants.emojiPadding)
            }
            .fixedSize(horizontal: true, vertical: true)

            if transaction.comment.isEmpty {
                Text(category.name)
                    .lineLimit(Constants.lineLimit)
            } else {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .lineLimit(Constants.lineLimit)
                    Text(transaction.comment)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(Constants.lineLimit)
                }
            }
            Spacer()

            VStack {
                Text(transaction.amount.formattedWithSeparator(currencySymbol: Constants.currencySymbol))
                Text(transaction.transactionDate.timeString(format: .twentyFour))
            }
            NavigationLink(Constants.emptyString) {
                Image(systemName: Constants.chevronRight)
                    .font(.system(size: Constants.chevronFontSize, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.leading, Constants.chevronPadding)
            }
        }
    }

    private enum Constants {
        static let circleAspectRatio: CGFloat = 1
        static let emojiPadding: CGFloat = 6
        static let lineLimit: Int = 1
        static let currencySymbol = "₽"
        static let chevronRight = "chevron.right"
        static let chevronFontSize: CGFloat = 13
        static let chevronPadding: CGFloat = 8
        static let emptyString = ""
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

        var body: some View {
            List {
                ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                    let category = categories.first { $0.id == transaction.categoryId }

                    Group {
                        if let category {
                            HistoryRow(transaction: transactions[index], category: category)
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
