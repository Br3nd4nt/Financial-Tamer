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

#Preview {
    let categories: [Category] = [
        Category( id: 1, name: "Зарплата", emoji: Character("💸"), direction: .income ),
        Category( id: 2, name: "Подработка", emoji: Character("🤑"), direction: .income ),
        Category( id: 3, name: "Аренда квартиры", emoji: Character("🏠"), direction: .outcome ),
        Category( id: 4, name: "Одежда", emoji: Character("👔"), direction: .outcome ),
        Category( id: 5, name: "Питомцы", emoji: Character("🐕"), direction: .outcome ),
        Category( id: 6, name: "Медицина", emoji: Character("😷"), direction: .outcome ),
        Category( id: 7, name: "Машина", emoji: Character("🏎️"), direction: .outcome )
    ]
    List {
        Section("Категории") {
            ForEach(categories) { category in
                CategoryRow(category: category)
            }
        }
    }
}
