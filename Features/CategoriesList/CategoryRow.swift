//
//  CategoryRow.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import SwiftUI

struct CategoryRow: View {
    var category: Category

    private var symbol: some View {
        ZStack {
            Circle()
                .fill(.categoryBackground)
                .aspectRatio(Constants.circleAspectRatio, contentMode: .fit)
            Text("\(category.emoji)")
                .padding(Constants.emojiPadding)
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(.trailing, Constants.trailingPadding)
    }

    var body: some View {
        HStack {
            symbol
            VStack(alignment: .leading) {
                Text(category.name)
            }

            Spacer()
        }
    }

    private enum Constants {
        static let circleAspectRatio: Double = 1
        static let emojiPadding: Double = 6
        static let trailingPadding: Double = 8
    }
}
