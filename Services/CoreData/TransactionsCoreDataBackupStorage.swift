import Foundation
import CoreData

final class TransactionsCoreDataBackupStorage: BackupStorageProtocol {
    typealias Item = Transaction
    typealias Action = BackupAction

    private let context: NSManagedObjectContext

    init() {
        self.context = CoreDataManager.shared.context
    }

    func addToBackup(_ item: Transaction, action: BackupAction) async throws {
        let cdBackupTransaction = CDBackupTransaction(context: context)
        cdBackupTransaction.id = Int32(item.id)
        cdBackupTransaction.accountId = Int32(item.accountId)
        cdBackupTransaction.categoryId = Int32(item.categoryId)
        cdBackupTransaction.amount = item.amount.formatted()
        cdBackupTransaction.transactionDate = item.transactionDate
        cdBackupTransaction.comment = item.comment
        cdBackupTransaction.createdAt = item.createdAt
        cdBackupTransaction.updatedAt = item.updatedAt
        cdBackupTransaction.action = action.rawValue

        CoreDataManager.shared.saveContext()
    }

    func getBackupItems() async throws -> [(item: Transaction, action: BackupAction)] {
        let request: NSFetchRequest<CDBackupTransaction> = CDBackupTransaction.fetchRequest()

        do {
            let cdBackupTransactions = try context.fetch(request)
            return cdBackupTransactions.compactMap { cdBackupTransaction in
                guard let amount = cdBackupTransaction.amount,
                      let transactionDate = cdBackupTransaction.transactionDate,
                      let createdAt = cdBackupTransaction.createdAt,
                      let updatedAt = cdBackupTransaction.updatedAt,
                      let actionString = cdBackupTransaction.action,
                      let action = BackupAction(rawValue: actionString) else {
                    return nil
                }

                let transaction = Transaction(
                    id: Int(cdBackupTransaction.id),
                    accountId: Int(cdBackupTransaction.accountId),
                    categoryId: Int(cdBackupTransaction.categoryId),
                    amount: Decimal(string: amount) ?? Decimal.zero,
                    transactionDate: transactionDate,
                    comment: cdBackupTransaction.comment ?? "",
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )

                return (item: transaction, action: action)
            }
        } catch {
            throw error
        }
    }

    func removeFromBackup(_ id: Int) async throws {
        let request: NSFetchRequest<CDBackupTransaction> = CDBackupTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let cdBackupTransactions = try context.fetch(request)
            for cdBackupTransaction in cdBackupTransactions {
                context.delete(cdBackupTransaction)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func clearBackup() async throws {
        let request: NSFetchRequest<CDBackupTransaction> = CDBackupTransaction.fetchRequest()

        do {
            let cdBackupTransactions = try context.fetch(request)
            for cdBackupTransaction in cdBackupTransactions {
                context.delete(cdBackupTransaction)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }
}
