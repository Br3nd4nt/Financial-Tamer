//
//  BankAccountDTO.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

struct BankAccountDTO: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    let createdAt: Date?
    let updatedAt: Date?
}
