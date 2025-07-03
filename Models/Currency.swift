//
//  Currency.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 03.07.2025.
//

enum Currency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case dollar = "USD"
    case euro = "EUR"

    var id: String {
        rawValue
    }

    var symbol: String {
        switch self {
        case .rub:
            return "₽"
        case .dollar:
            return "$"
        case .euro:
            return "€"
        }
    }

    var displayName: String {
        switch self {
        case .rub:
            return "Российский Рубль ₽"
        case .dollar:
            return "Доллар США $"
        case .euro:
            return "Евро €"
        }
    }
}
