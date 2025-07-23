//
//  NetworkClient.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let requestBuilder: RequestBuilderProtocol

    init(session: URLSession = .shared, requestBuilder: RequestBuilderProtocol = RequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try await request(endpoint, body: nil as Data?)
    }

    func request<T: Decodable, U: Encodable>(_ endpoint: Endpoint, body: U?) async throws -> T {
        guard let request = await requestBuilder.buildRequest(from: endpoint, body: body) else {
            throw NetworkError.invalidRequest
        }

        // Debug print the outgoing request
        print("[NETWORK DEBUG] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("[NETWORK DEBUG] Headers:")
            for (key, value) in headers {
                print("  \(key): \(value)")
            }
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[NETWORK DEBUG] Body: \(bodyString)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, url: request.url, responseBody: responseBody)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            return try await Task.detached(priority: .userInitiated) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }

                    let fallbackFormatter = ISO8601DateFormatter()
                    fallbackFormatter.formatOptions = [.withInternetDateTime]
                    if let date = fallbackFormatter.date(from: dateString) {
                        return date
                    }

                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date string does not match expected format")
                }
                return try decoder.decode(T.self, from: data)
            }.value
        } catch {
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
            throw NetworkError.decodingError(url: request.url, responseBody: responseBody, underlyingError: error)
        }
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Data?) async throws -> T {
        guard let request = await requestBuilder.buildRequest(from: endpoint, body: body) else {
            throw NetworkError.invalidRequest
        }

        // Debug print the outgoing request
        print("[NETWORK DEBUG] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("[NETWORK DEBUG] Headers:")
            for (key, value) in headers {
                print("  \(key): \(value)")
            }
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[NETWORK DEBUG] Body: \(bodyString)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, url: request.url, responseBody: responseBody)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            return try await Task.detached(priority: .userInitiated) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)

                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }

                    let fallbackFormatter = ISO8601DateFormatter()
                    fallbackFormatter.formatOptions = [.withInternetDateTime]
                    if let date = fallbackFormatter.date(from: dateString) {
                        return date
                    }

                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date string does not match expected format")
                }
                return try decoder.decode(T.self, from: data)
            }.value
        } catch {
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
            throw NetworkError.decodingError(url: request.url, responseBody: responseBody, underlyingError: error)
        }
    }
}
