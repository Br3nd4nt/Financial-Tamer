//
//  CategoriesService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class CategoriesService: CategoriesProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func getCategories() async throws -> [Category] {
        let endpoint = CategoriesEndpoint.getAllCategories
        let dtos: [CategoryDTO] = try await networkClient.request(endpoint)
        return ModelMapper.map(dtos)
    }

    func getCategoriesDyDirection(direction: Direction) async throws -> [Category] {
        let endpoint = CategoriesEndpoint.getCategoriesByDirection(direction: direction)
        let dtos: [CategoryDTO] = try await networkClient.request(endpoint)
        return ModelMapper.map(dtos)
    }
}

// MARK: - Endpoints
private enum CategoriesEndpoint: Endpoint {
    case getAllCategories
    case getCategoriesByDirection(direction: Direction)

    var baseURL: URL {
        Config.apiBaseURL
    }

    var path: String {
        switch self {
        case .getAllCategories:
            return "/categories"
        case .getCategoriesByDirection(let direction):
            let isIncome = direction == .income ? "true" : "false"
            return "/categories/type/\(isIncome)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var headers: [String: String] {
        [:]
    }

    var parameters: [String: Any] {
        switch self {
        case .getAllCategories:
            return [:]
        case .getCategoriesByDirection:
            return [:]
        }
    }
}
