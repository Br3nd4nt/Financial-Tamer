//
//  NetworkClientProtocol.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 18.07.2025.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request<T: Decodable, U: Encodable>(_ endpoint: Endpoint, body: U?) async throws -> T
    func request<T: Decodable>(_ endpoint: Endpoint, body: Data?) async throws -> T
}
