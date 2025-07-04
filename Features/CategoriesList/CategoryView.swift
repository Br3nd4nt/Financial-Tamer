//
//  CategoryView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.incomeCategories.isEmpty {
                    Section(Constants.incomeCategories) {
                        ForEach(viewModel.incomeCategories) { category in
                            CategoryRow(category: category)
                        }
                    }
                }
                if !viewModel.outcomeCategories.isEmpty {
                    Section(Constants.outcomeCategories) {
                        ForEach(viewModel.outcomeCategories) { category in
                            CategoryRow(category: category)
                        }
                    }
                }
            }
            .navigationTitle(Constants.title)
        }
        .searchable(text: $viewModel.searchText)
    }

    private enum Constants {
        static let title = "Мои статьи"
        static let incomeCategories = "Доход"
        static let outcomeCategories = "Затраты"
    }
}

#Preview {
    CategoryView()
}
