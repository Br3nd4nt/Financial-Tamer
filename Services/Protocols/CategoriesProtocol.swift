//
//  CategoriesProtocol.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

protocol CategoriesProtocol {
    func getCategories() async throws -> [Category]
    func getCategoriesDyDirection(direction: Direction) async throws -> [Category]
}
