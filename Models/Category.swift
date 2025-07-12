//
//  Category.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

struct Category: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}

struct CategoryAnalytics: Identifiable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
    let description: String
    let totalValue: Decimal
    let percentage: Decimal
    let lastTransactionDate: Date

    init(_ category: Category, description: String = "", totalValue: Decimal, percentage: Decimal, lastTransactionDate: Date?) {
        self.id = category.id
        self.name = category.name
        self.emoji = category.emoji
        self.direction = category.direction
        self.description = description
        self.totalValue = totalValue
        self.percentage = percentage
        guard let lastTransactionDate else {
            self.lastTransactionDate = Date(timeIntervalSince1970: 0)
            return
        }
        self.lastTransactionDate = lastTransactionDate
    }
}
