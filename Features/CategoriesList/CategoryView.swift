//
//  CategoryView.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel: CategoryViewModel
    @StateObject private var errorHandler = ErrorHandler()

    @State private var showCreateCategory = false

    init() {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(errorHandler: ErrorHandler()))
    }

    private var loadingView: some View {
        VStack(spacing: Constants.loadingVStackSpacing) {
            ProgressView()
                .scaleEffect(Constants.progressScale)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            Text(Constants.loadingText)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    private var emptyView: some View {
        VStack(spacing: Constants.emptyVStackSpacing) {
            Image(systemName: Constants.emptyIcon)
                .font(.system(size: Constants.emptyIconSize))
                .foregroundColor(.secondary)
            Text(Constants.noCategoriesText)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(Constants.emptyDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    private var mainList: some View {
        List {
            ForEach(viewModel.filteredCategories) { category in
                CategoryRow(category: category)
            }
        }
        .listStyle(.insetGrouped)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredCategories.isEmpty {
                    emptyView
                } else {
                    mainList
                }
            }
            .navigationTitle(Constants.navigationTitle)
            .searchable(text: $viewModel.searchText, prompt: Constants.searchPrompt)
            .task {
                await viewModel.loadCategories()
            }
            .refreshable {
                await viewModel.loadCategories()
            }
            .errorAlert(errorHandler: errorHandler)
        }
        .onAppear {
            viewModel.errorHandler = errorHandler
        }
    }

    private enum Constants {
        static let loadingVStackSpacing: Double = 16
        static let progressScale = 1.5
        static let loadingText = "Загрузка категорий..."
        static let emptyVStackSpacing: Double = 16
        static let emptyIcon = "folder"
        static let emptyIconSize: Double = 48
        static let noCategoriesText = "Нет категорий"
        static let emptyDescription = "Здесь будут отображаться ваши категории для доходов и расходов"
        static let plusIcon = "plus"
        static let navigationTitle = "Категории"
        static let searchPrompt = "Поиск категорий"
        static let newCategoryTitle = "Новая категория"
        static let cancel = "Отмена"
        static let save = "Сохранить"
        static let namePlaceholder = "Название"
        static let emojiPlaceholder = "Эмодзи"
    }
}
