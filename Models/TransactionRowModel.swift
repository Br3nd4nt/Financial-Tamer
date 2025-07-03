//
//  TransactionRowModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

struct TransactionRowModel: Identifiable {
    // объединяем Transaction и Category чтобы избежать сложностей при отображении
    // возможно стоит провести рефакторинг моделей в будущем

    let transaction: Transaction
    let category: Category
    let id: Int
}
