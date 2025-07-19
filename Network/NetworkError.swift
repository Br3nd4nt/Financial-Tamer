//
//  NetworkError.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 18.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case noData
    case httpError(statusCode: Int, url: URL?, responseBody: String?)
    case decodingError(url: URL?, responseBody: String?, underlyingError: Error)
}
