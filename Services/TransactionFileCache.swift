//
//  TransactionFileCache.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

final class TransactionFileCache {
    static let shared = TransactionFileCache(filename: Constants.defaultFilename)!
    private(set) var transactions: [Transaction] = []
    private let filename: String
    private let fileURL: URL

    private init?(filename: String) {
        self.filename = filename

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory")
            return nil
        }

        self.fileURL = documentsDirectory.appendingPathComponent(filename)
    }

    func loadFromFile() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)

            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                return
            }

            self.transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
        } catch {
            print("Error loading transactions: \(error)")
        }
    }

    func addTransaction(_ transaction: Transaction) throws {
        if transactions.contains(where: { $0.id == transaction.id }) {
            throw CacheError.duplicateTransaction
        }

        transactions.append(transaction)
        try saveToFile()
    }

    func removeTransaction(withId id: Int) throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw CacheError.transactionNotFound
        }

        transactions.remove(at: index)
        try saveToFile()
    }

    func saveToFile() throws {
        let transactionsArray = transactions.map(\.jsonObject)
        let data = try JSONSerialization.data(withJSONObject: transactionsArray, options: [.prettyPrinted])
        try data.write(to: fileURL, options: [.atomic])
    }

    // MARK: Transaction Cache Errors
    enum CacheError: Error {
        case duplicateTransaction
        case transactionNotFound
        case fileSaveError
    }

    private enum Constants {
        static let defaultFilename = "default_transactions.json"
    }
}
