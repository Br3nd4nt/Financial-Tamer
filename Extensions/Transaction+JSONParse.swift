//
//  Transaction+JSONParse.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 09.06.2025.
//

import Foundation

extension Transaction {
    var jsonObject: Any {
        [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount.doubleValue,
            "transactionDate": dateFormatter.string(from: transactionDate),
            "comment": comment,
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt)
        ]
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dictionary = jsonObject as? [String: Any],
            let id = dictionary["id"] as? Int,
            let accountId = dictionary["accountId"] as? Int,
            let categoryId = dictionary["categoryId"] as? Int,
            let amountDouble = dictionary["amount"] as? Double,
            let transactionDateString = dictionary["transactionDate"] as? String,
            let transactionDate = dateFormatter.date(from: transactionDateString),
            let comment = dictionary["comment"] as? String,
            let createdAtString = dictionary["createdAt"] as? String,
            let createdAt = dateFormatter.date(from: createdAtString),
            let updatedAtString = dictionary["updatedAt"] as? String,
            let updatedAt = dateFormatter.date(from: updatedAtString)
        else { return nil }
        let amount = Decimal(amountDouble)

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
