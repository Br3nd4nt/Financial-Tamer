import Foundation
import CoreData

final class BankAccountsCoreDataStorage: LocalStorageProtocol {
    typealias Item = BankAccount

    private let context: NSManagedObjectContext

    init() {
        self.context = CoreDataManager.shared.context
    }

    func getAll() async throws -> [BankAccount] {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()

        do {
            let cdBankAccounts = try context.fetch(request)
            return cdBankAccounts.compactMap { cdBankAccount in
                guard let balance = cdBankAccount.balance,
                      let currency = cdBankAccount.currency,
                      let name = cdBankAccount.name,
                      let createdAt = cdBankAccount.createdAt,
                      let updatedAt = cdBankAccount.updatedAt else {
                    return nil
                }

                return BankAccount(
                    id: Int(cdBankAccount.id),
                    userId: Int(cdBankAccount.userId),
                    name: name,
                    balance: Decimal(string: balance) ?? Decimal.zero,
                    currency: Currency(rawValue: currency) ?? .dollar,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } catch {
            throw error
        }
    }

    func getById(_ id: Int) async throws -> BankAccount? {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1

        do {
            let cdBankAccount = try context.fetch(request).first
            guard let cdBankAccount,
                  let balance = cdBankAccount.balance,
                  let currency = cdBankAccount.currency,
                  let name = cdBankAccount.name,
                  let createdAt = cdBankAccount.createdAt,
                  let updatedAt = cdBankAccount.updatedAt else {
                return nil
            }

            return BankAccount(
                id: Int(cdBankAccount.id),
                userId: Int(cdBankAccount.userId),
                name: name,
                balance: Decimal(string: balance) ?? Decimal.zero,
                currency: Currency(rawValue: currency) ?? .dollar,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        } catch {
            throw error
        }
    }

    func create(_ item: BankAccount) async throws {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        let existingAccounts = try context.fetch(request)
        if !existingAccounts.isEmpty {
            return
        }

        let cdBankAccount = CDBankAccount(context: context)
        cdBankAccount.id = Int32(item.id)
        cdBankAccount.userId = Int32(item.userId)
        cdBankAccount.name = item.name
        cdBankAccount.balance = item.balance.formatted()
        cdBankAccount.currency = item.currency.rawValue
        cdBankAccount.createdAt = item.createdAt
        cdBankAccount.updatedAt = item.updatedAt

        CoreDataManager.shared.saveContext()
    }

    func update(_ item: BankAccount) async throws {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", item.id)

        do {
            let cdBankAccount = try context.fetch(request).first
            guard let cdBankAccount else {
                throw NSError(domain: "CoreDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Bank account not found"])
            }

            cdBankAccount.userId = Int32(item.userId)
            cdBankAccount.name = item.name
            cdBankAccount.balance = item.balance.formatted()
            cdBankAccount.currency = item.currency.rawValue
            cdBankAccount.updatedAt = item.updatedAt

            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func delete(_ id: Int) async throws {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let cdBankAccounts = try context.fetch(request)
            for cdBankAccount in cdBankAccounts {
                context.delete(cdBankAccount)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }

    func clear() async throws {
        let request: NSFetchRequest<CDBankAccount> = CDBankAccount.fetchRequest()

        do {
            let cdBankAccounts = try context.fetch(request)
            for cdBankAccount in cdBankAccounts {
                context.delete(cdBankAccount)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            throw error
        }
    }
}
