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
