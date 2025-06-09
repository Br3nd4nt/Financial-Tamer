//
//  Item.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
