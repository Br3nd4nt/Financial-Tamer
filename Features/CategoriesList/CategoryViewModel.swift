//
//  CategoryViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import SwiftUI
import Foundation
import Fuse

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var searchText = ""

    private let categoryService: CategoriesProtocol

    private let fuse = Fuse(threshold: 0.4)
    private var fusePatterns: [String: Fuse.Pattern] = [:]

    init(categoryService: CategoriesProtocol = CategoriesServiceMock.shared) {
        self.categoryService = categoryService
        Task {
            await fetchCategories()
        }
    }

    var categories: [Category] {
        guard !searchText.isEmpty else {
            return allCategories
        }

        guard let pattern = getPattern(for: searchText) else {
            return []
        }

        return searchCategories(with: pattern)
    }

    var incomeCategories: [Category] {
        categories.filter { $0.direction == .income }
    }

    var outcomeCategories: [Category] {
        categories.filter { $0.direction == .outcome }
    }

    func fetchCategories() async {
        do {
            allCategories = try await categoryService.getCategories()
        } catch {
            print("Failed to load categories: \(error)")
            self.allCategories = []
        }
    }

    // MARK: - private helpers

    private func getPattern(for query: String) -> Fuse.Pattern? {
        if let cachedPattern = fusePatterns[query] {
            return cachedPattern
        }

        if let newPattern = fuse.createPattern(from: query) {
            fusePatterns[query] = newPattern
            return newPattern
        }

        return nil
    }

    private func searchCategories(with pattern: Fuse.Pattern) -> [Category] {
        let searchResults: [(category: Category, score: Double)] = allCategories.compactMap { category in
            guard let result = fuse.search(pattern, in: category.name) else {
                return nil
            }
            return (category: category, score: result.score)
        }

        let sortedResults = searchResults.sorted { first, second in
            first.score < second.score
        }

        return sortedResults.map(\.category)
    }
}
