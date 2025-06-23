//
//  Numeric+.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 20.06.2025.
//

import Foundation

extension Numeric {
    func formattedWithSeparator(currencySymbol: String = "₽") -> String {
        if let number = self as? NSNumber,
           let formatted = separatorFormatter.string(from: number) {
            return "\(formatted) \(currencySymbol)"
        }
        return "\(self) \(currencySymbol)"
    }
}

// static не получается в extension засунуть, поэтому вот так
public let separatorFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.maximumFractionDigits = 0
    return formatter
}()
