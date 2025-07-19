import Foundation
import CoreData

final class CategoriesCoreDataStorage: LocalStorageProtocol {
    typealias Item = Category

    private let context: NSManagedObjectContext

    init() {
        self.context = CoreDataManager.shared.context
    }

    func getAll() async throws -> [Category] {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()

        do {
            let cdCategories = try context.fetch(request)
            return cdCategories.compactMap { cdCategory in
                guard let name = cdCategory.name,
                      let emoji = cdCategory.emoji,
                      let direction = cdCategory.direction else {
                    return nil
                }

                return Category(
                    id: Int(cdCategory.id),
                    name: name,
                    emoji: Character(emoji),
                    direction: Direction(rawValue: direction) ?? .outcome
                )
            }
        } catch {
            throw error
        }
    }

    func getById(_ id: Int) async throws -> Category? {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1

        do {
            let cdCategory = try context.fetch(request).first
            guard let cdCategory,
                  let name = cdCategory.name,
                  let emoji = cdCategory.emoji,
                  let direction = cdCategory.direction else {
                return nil
            }

            return Category(
                    id: Int(cdCategory.id),
                    name: name,
                    emoji: Character(emoji),
                    direction: Direction(rawValue: direction) ?? .outcome
                )
        } catch {
            throw error
        }
    }

    func create(_ item: Category) async throws {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        let existingCategories = try context.fetch(request)
        if !existingCategories.isEmpty {
            return
        }

        let cdCategory = CDCategory(context: context)
        cdCategory.id = Int32(item.id)
        cdCategory.name = item.name
        cdCategory.emoji = String(item.emoji)
        cdCategory.direction = item.direction.rawValue

        CoreDataManager.shared.saveContext()
    }

    func update(_ item: Category) async throws {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        do {
            let cdCategory = try context.fetch(request).first
            guard let cdCategory else {
                throw NSError(domain: "CoreDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
            }

            cdCategory.name = item.name
            cdCategory.emoji = String(item.emoji)
            cdCategory.direction = item.direction.rawValue

            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func delete(_ id: Int) async throws {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let cdCategories = try context.fetch(request)
            for cdCategory in cdCategories {
                context.delete(cdCategory)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func clear() async throws {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()

        do {
            let cdCategories = try context.fetch(request)
            for cdCategory in cdCategories {
                context.delete(cdCategory)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }
}
