//
//  Decimal+ToDouble.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
