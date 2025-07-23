//
//  CategoryViewModel.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var searchText = ""
    @Published var isLoading = false

    private let categoryService: CategoriesProtocol
    var errorHandler: ErrorHandler
    private let threshold = 0.4
    private var patterns: [String: Pattern] = [:]

    init(categoryService: CategoriesProtocol = ServiceFactory.shared.categoriesService, errorHandler: ErrorHandler) {
        self.categoryService = categoryService
        self.errorHandler = errorHandler
        Task {
            await loadCategories()
        }
    }

    var filteredCategories: [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        guard let pattern = getPattern(for: searchText) else {
            return []
        }
        return searchCategories(with: pattern)
    }

    var incomeCategories: [Category] {
        filteredCategories.filter { $0.direction == .income }
    }

    var outcomeCategories: [Category] {
        filteredCategories.filter { $0.direction == .outcome }
    }

    func loadCategories() async {
        isLoading = true

        do {
            let loadedCategories = try await categoryService.getCategories()
            self.categories = loadedCategories
        } catch {
            errorHandler.handleError(error, context: "CategoryViewModel.loadCategories", userMessage: "Не удалось загрузить категории")
        }

        isLoading = false
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
        let searchResults: [(category: Category, score: Double)] = categories.compactMap { category in
            let result = fuzzyMatch(pattern, in: category.name)
            if result.isMatch && result.score >= threshold {
                return (category: category, score: result.score)
            }
            return nil
        }
        let sortedResults = searchResults.sorted { first, second in
            first.score > second.score
        }
        return sortedResults.map(\.category)
    }
}
