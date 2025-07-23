//
//  RequestBuilder.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 18.07.2025.
//

import Foundation

final class RequestBuilder: RequestBuilderProtocol {
    func buildRequest<T>(from endpoint: Endpoint, body: T?) async -> URLRequest? {
        var url = endpoint.baseURL.appendingPathComponent(endpoint.path)

        if endpoint.method == .get && !endpoint.parameters.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = endpoint.parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            if let finalURL = components?.url {
                url = finalURL
            }
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        request.addValue("Bearer \(Config.bearerToken)", forHTTPHeaderField: "Authorization")

        endpoint.headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        if let body, endpoint.method != .get {
            if let dataBody = body as? Data {
                request.httpBody = dataBody
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } else if let encodableBody = body as? Encodable {
                do {
                    let encodedData = try await Task.detached(priority: .userInitiated) {
                        try JSONEncoder().encode(encodableBody)
                    }.value
                    request.httpBody = encodedData
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    return nil
                }
            }
        }

        return request
    }
}
