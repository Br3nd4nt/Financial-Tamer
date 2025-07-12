//
//  Date+dayEdges.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 12.07.2025.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        let start = Calendar.current.startOfDay(for: self)
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: start) ?? self
    }
}
