//
//  Unit_Tests.swift
//  Unit Tests
//
//  Created by br3nd4nt on 09.06.2025.
//

import Testing
import Foundation

@testable import Financial_Tamer

struct TransactionParseUnitTests {
    @Test func transactionJSONtoObject() async throws {
        let jsonObject: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 1,
            "amount": 100.0,
            "transactionDate": "2025-06-09T13:16:09.705Z",
            "comment": "test comment",
            "createdAt": "2025-06-09T13:16:09.705Z",
            "updatedAt": "2025-06-09T13:16:09.705Z"
        ]

        let obj: Transaction = try #require(Transaction.parse(jsonObject: jsonObject))

        #expect(obj.id == 1)
        #expect(obj.accountId == 1)
        #expect(obj.categoryId == 1)
        #expect(obj.comment == "test comment")
    }

    @Test func transactionToObject() async throws {
        let date = dateFormatter.date(from: "2025-06-09T13:16:09.705Z")!
        let transaction = Transaction(
            id: 1,
            accountId: 1,
            categoryId: 1,
            amount: 100.0,
            transactionDate: date,
            comment: "test comment",
            createdAt: date,
            updatedAt: date
        )
        let object = try #require(transaction.jsonObject as? [String: Any])
        #expect(object["id"] as? Int == 1)
        #expect(object["accountId"] as? Int == 1)
        #expect(object["categoryId"] as? Int == 1)
        #expect(object["amount"] as? Double == 100.0)
        #expect(object["transactionDate"] as? String == "2025-06-09T13:16:09.705Z")
        #expect(object["comment"] as? String == "test comment")
        #expect(object["createdAt"] as? String == "2025-06-09T13:16:09.705Z")
        #expect(object["updatedAt"] as? String == "2025-06-09T13:16:09.705Z")
    }
}
