//
//  DateFormatter.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.06.2025.
//

import Foundation

public let dateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()
