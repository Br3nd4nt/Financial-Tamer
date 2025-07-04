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
        // implement fizzy search
        return allCategories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
}
