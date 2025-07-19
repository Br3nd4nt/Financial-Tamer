//
//  HistoryRow.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import SwiftUI

struct HistoryRow: View {
    var fullTransaction: TransactionFull

    var body: some View {
        NavigationLink(destination: EmptyView()) {
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
                VStack {
                    Text(fullTransaction.amount.formattedWithSeparator(currencySymbol: fullTransaction.account.currency.symbol))
                    Text(fullTransaction.transactionDate.timeString(format: .twentyFour))
                }
            }
        }
        .contentShape(Rectangle())
    }

    private enum Constants {
        static let circleAspectRatio: Double = 1
        static let emojiPadding: Double = 6
        static let lineLimit = 1
        static let currencySymbol = "₽"
        static let chevronRight = "chevron.right"
        static let chevronFontSize: Double = 13
        static let chevronPadding: Double = 8
        static let emptyString = ""
    }
}
