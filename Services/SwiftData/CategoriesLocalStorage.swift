import Foundation
import SwiftData

final class CategoriesLocalStorage: LocalStorageProtocol {
    typealias Item = Category
    
    private let modelContext: ModelContext
    
    init() throws {
        self.modelContext = SharedModelContainer.shared.modelContext
    }
    
    func getAll() async throws -> [Category] {
        return try await MainActor.run {
            let descriptor = FetchDescriptor<LocalCategory>()
            let localCategories = try modelContext.fetch(descriptor)
            return localCategories.map { $0.toCategory() }
        }
    }
    
    func getById(_ id: Int) async throws -> Category? {
        return try await MainActor.run {
            let descriptor = FetchDescriptor<LocalCategory>(
                predicate: #Predicate<LocalCategory> { localCategory in
                    localCategory.id == id
                }
            )
            let localCategory = try modelContext.fetch(descriptor).first
            return localCategory?.toCategory()
        }
    }
    
    func create(_ item: Category) async throws {
        try await MainActor.run {
            let itemId = item.id
            let descriptor = FetchDescriptor<LocalCategory>(
                predicate: #Predicate<LocalCategory> { $0.id == itemId }
            )
            let existingCategories = try modelContext.fetch(descriptor)
            if !existingCategories.isEmpty {
                return
            }
            
            let localCategory = LocalCategory(from: item)
            modelContext.insert(localCategory)
            try modelContext.save()
        }
    }
    
    func update(_ item: Category) async throws {
        try await MainActor.run {
            let itemId = item.id
            let descriptor = FetchDescriptor<LocalCategory>(
                predicate: #Predicate<LocalCategory> { localCategory in
                    localCategory.id == itemId
                }
            )
            let localCategory = try modelContext.fetch(descriptor).first
            
            if let localCategory = localCategory {
                localCategory.name = item.name
                localCategory.emoji = String(item.emoji)
                localCategory.direction = item.direction.rawValue
                try modelContext.save()
            } else {
                throw LocalStorageError.itemNotFound
            }
        }
    }
    
    func delete(_ id: Int) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalCategory>(
                predicate: #Predicate<LocalCategory> { localCategory in
                    localCategory.id == id
                }
            )
            let localCategories = try modelContext.fetch(descriptor)
            
            for localCategory in localCategories {
                modelContext.delete(localCategory)
            }
            try modelContext.save()
        }
    }
    
    func clear() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<LocalCategory>()
            let localCategories = try modelContext.fetch(descriptor)
            
            for localCategory in localCategories {
                modelContext.delete(localCategory)
            }
            try modelContext.save()
        }
    }
} 