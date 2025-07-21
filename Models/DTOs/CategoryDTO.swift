//
//  CategoryDTO.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}
