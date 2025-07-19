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

    @State private var searchText = ""
    @State private var showCreateCategory = false

    init() {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(errorHandler: ErrorHandler()))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))

                        Text("Загрузка категорий...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else if viewModel.filteredCategories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("Нет категорий")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text("Здесь будут отображаться ваши категории для доходов и расходов")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(viewModel.filteredCategories) { category in
                            CategoryRow(category: category)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Категории")
            .searchable(text: $searchText, prompt: "Поиск категорий")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.loadCategories()
            }
            .refreshable {
                await viewModel.loadCategories()
            }
            .sheet(isPresented: $showCreateCategory) {
                CreateCategoryView()
            }
            .errorAlert(errorHandler: errorHandler)
        }
        .onAppear {
            viewModel.errorHandler = errorHandler
        }
    }
}

struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var emoji = "📁"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название", text: $name)
                    TextField("Эмодзи", text: $emoji)
                }
            }
            .navigationTitle("Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        // TODO: Implement category creation
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CategoryView()
}
