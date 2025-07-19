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

    init(categoryService: CategoriesProtocol = ServiceFactory.shared.categoriesService, errorHandler: ErrorHandler) {
        self.categoryService = categoryService
        self.errorHandler = errorHandler
        Task {
            await loadCategories()
        }
    }

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { category in
            let searchLower = searchText.lowercased()
            let nameLower = category.name.lowercased()
            let emojiString = String(category.emoji)

            return nameLower.contains(searchLower) || emojiString.contains(searchLower)
        }
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
}
