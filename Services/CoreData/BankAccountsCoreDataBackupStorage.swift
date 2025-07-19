import Foundation
import CoreData

final class BankAccountsCoreDataBackupStorage: BackupStorageProtocol {
    typealias Item = BankAccount
    typealias Action = BackupAction

    private let context: NSManagedObjectContext

    init() {
        self.context = CoreDataManager.shared.context
    }

    func addToBackup(_ item: BankAccount, action: BackupAction) async throws {
        let cdBackupBankAccount = CDBackupBankAccount(context: context)
        cdBackupBankAccount.id = Int32(item.id)
        cdBackupBankAccount.userId = Int32(item.userId)
        cdBackupBankAccount.name = item.name
        cdBackupBankAccount.balance = item.balance.formatted()
        cdBackupBankAccount.currency = item.currency.rawValue
        cdBackupBankAccount.createdAt = item.createdAt
        cdBackupBankAccount.updatedAt = item.updatedAt
        cdBackupBankAccount.action = action.rawValue

        CoreDataManager.shared.saveContext()
    }

    func getBackupItems() async throws -> [(item: BankAccount, action: BackupAction)] {
        let request: NSFetchRequest<CDBackupBankAccount> = CDBackupBankAccount.fetchRequest()

        do {
            let cdBackupBankAccounts = try context.fetch(request)
            return cdBackupBankAccounts.compactMap { cdBackupBankAccount in
                guard let balance = cdBackupBankAccount.balance,
                      let currency = cdBackupBankAccount.currency,
                      let name = cdBackupBankAccount.name,
                      let createdAt = cdBackupBankAccount.createdAt,
                      let updatedAt = cdBackupBankAccount.updatedAt,
                      let actionString = cdBackupBankAccount.action,
                      let action = BackupAction(rawValue: actionString) else {
                    return nil
                }

                let bankAccount = BankAccount(
                    id: Int(cdBackupBankAccount.id),
                    userId: Int(cdBackupBankAccount.userId),
                    name: name,
                    balance: Decimal(string: balance) ?? Decimal.zero,
                    currency: Currency(rawValue: currency) ?? .dollar,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )

                return (item: bankAccount, action: action)
            }
        } catch {
            throw error
        }
    }

    func removeFromBackup(_ id: Int) async throws {
        let request: NSFetchRequest<CDBackupBankAccount> = CDBackupBankAccount.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let cdBackupBankAccounts = try context.fetch(request)
            for cdBackupBankAccount in cdBackupBankAccounts {
                context.delete(cdBackupBankAccount)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func clearBackup() async throws {
        let request: NSFetchRequest<CDBackupBankAccount> = CDBackupBankAccount.fetchRequest()

        do {
            let cdBackupBankAccounts = try context.fetch(request)
            for cdBackupBankAccount in cdBackupBankAccounts {
                context.delete(cdBackupBankAccount)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }
}
