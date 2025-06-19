//
//  Transaction+CSVParse.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

extension Transaction {
    
    func parseCSV(_ csv: String) throws -> [Transaction] {
        var transactions: [Transaction] = []
        
        let lines = csv.components(separatedBy: CharacterSet(charactersIn: "\n\r"))
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard lines.count > 1 else { return [] }
        
        let headers = lines[0].components(separatedBy: ",")
        
        for line in lines.dropFirst() {
            let values = line.split(separator: ",").map {$0.trimmingCharacters(in: .whitespaces)}
            
            guard values.count == headers.count else { continue }
            
            var rowDict = [String: String]()
            for (index, header) in headers.enumerated() {
                rowDict[header] = values[index]
            }
            
            guard
                let id = Int(rowDict["id"] ?? ""),
                let accountId = Int(rowDict["accountId"] ?? ""),
                let categoryId = Int(rowDict["categoryId"] ?? ""),
                let amountDouble = Double(rowDict["amount"] ?? ""),
                let comment = rowDict["comment"],
                let transactionDate = dateFormatter.date(from: rowDict["transactionDate"] ?? ""),
                let createdAt = dateFormatter.date(from: rowDict["createdAt"] ?? ""),
                let updatedAt = dateFormatter.date(from: rowDict["updatedAt"] ?? "")
            else {continue}
            
            transactions.append(Transaction(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                amount: Decimal(amountDouble),
                transactionDate: transactionDate,
                comment: comment,
                createdAt: createdAt,
                updatedAt: updatedAt))
        }
        return transactions
    }
}
