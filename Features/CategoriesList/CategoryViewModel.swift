//
//  CategoryViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import SwiftUI
import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var searchText = ""

    private let categoryService: CategoriesProtocol

    private var patterns: [String: Pattern] = [:]
    private let threshold = 0.4

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

    private func getPattern(for query: String) -> Pattern? {
        if let cachedPattern = patterns[query] {
            return cachedPattern
        }

        let newPattern = Pattern(query)
        patterns[query] = newPattern
        return newPattern
    }

    private func searchCategories(with pattern: Pattern) -> [Category] {
        let searchResults: [(category: Category, score: Double)] = allCategories.compactMap { category in
            let result = fuzzyMatch(pattern, in: category.name)
            if result.isMatch && result.score >= threshold {
                return (category: category, score: result.score)
            }
            return nil
        }

        let sortedResults = searchResults.sorted { first, second in
            first.score > second.score
        }
        print(sortedResults)
        return sortedResults.map(\.category)
    }
}
