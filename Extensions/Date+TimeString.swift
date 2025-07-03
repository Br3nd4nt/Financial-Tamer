//
//  Date+TimeString.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 21.06.2025.
//

import Foundation

extension Date {
    enum TimeFormat {
        case system
        case twentyFour
        case twelve
    }

    func timeString(format: TimeFormat = .system) -> String {
        let formatter = DateFormatter()

        switch format {
        case .system:
            formatter.timeStyle = .short
            formatter.dateStyle = .none

        case .twentyFour:
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(
                identifier: "ru_RU"
            )

        case .twelve:
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(
                identifier: "us_US"
            )
        }

        return formatter.string(from: self)
    }
}
