import Foundation
import CoreData

final class TransactionsCoreDataStorage: LocalStorageProtocol {
    typealias Item = Transaction

    private let context: NSManagedObjectContext

    init() {
        self.context = CoreDataManager.shared.context
    }

    func getAll() async throws -> [Transaction] {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()

        do {
            let cdTransactions = try context.fetch(request)
            return cdTransactions.compactMap { cdTransaction in
                guard let amount = cdTransaction.amount,
                      let transactionDate = cdTransaction.transactionDate,
                      let createdAt = cdTransaction.createdAt,
                      let updatedAt = cdTransaction.updatedAt else {
                    return nil
                }

                return Transaction(
                    id: Int(cdTransaction.id),
                    accountId: Int(cdTransaction.accountId),
                    categoryId: Int(cdTransaction.categoryId),
                    amount: Decimal(string: amount) ?? Decimal.zero,
                    transactionDate: transactionDate,
                    comment: cdTransaction.comment ?? "",
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } catch {
            throw error
        }
    }

    func getById(_ id: Int) async throws -> Transaction? {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1

        do {
            let cdTransaction = try context.fetch(request).first
            guard let cdTransaction,
                  let amount = cdTransaction.amount,
                  let transactionDate = cdTransaction.transactionDate,
                  let createdAt = cdTransaction.createdAt,
                  let updatedAt = cdTransaction.updatedAt else {
                return nil
            }

            return Transaction(
                id: Int(cdTransaction.id),
                accountId: Int(cdTransaction.accountId),
                categoryId: Int(cdTransaction.categoryId),
                amount: Decimal(string: amount) ?? Decimal.zero,
                transactionDate: transactionDate,
                comment: cdTransaction.comment ?? "",
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        } catch {
            throw error
        }
    }

    func create(_ item: Transaction) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        let existingTransactions = try context.fetch(request)
        if !existingTransactions.isEmpty {
            return
        }

        let cdTransaction = CDTransaction(context: context)
        cdTransaction.id = Int32(item.id)
        cdTransaction.accountId = Int32(item.accountId)
        cdTransaction.categoryId = Int32(item.categoryId)
        cdTransaction.amount = item.amount.formatted()
        cdTransaction.transactionDate = item.transactionDate
        cdTransaction.comment = item.comment
        cdTransaction.createdAt = item.createdAt
        cdTransaction.updatedAt = item.updatedAt

        CoreDataManager.shared.saveContext()
    }

    func update(_ item: Transaction) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        do {
            let cdTransaction = try context.fetch(request).first
            guard let cdTransaction else {
                throw NSError(domain: "CoreDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
            }

            cdTransaction.accountId = Int32(item.accountId)
            cdTransaction.categoryId = Int32(item.categoryId)
            cdTransaction.amount = item.amount.formatted()
            cdTransaction.transactionDate = item.transactionDate
            cdTransaction.comment = item.comment
            cdTransaction.updatedAt = item.updatedAt

            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func delete(_ id: Int) async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let cdTransactions = try context.fetch(request)
            for cdTransaction in cdTransactions {
                context.delete(cdTransaction)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func clear() async throws {
        let request: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()

        do {
            let cdTransactions = try context.fetch(request)
            for cdTransaction in cdTransactions {
                context.delete(cdTransaction)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }
}
