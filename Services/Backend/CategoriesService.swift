//
//  CategoriesService.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

final class CategoriesService: CategoriesProtocol {
    private let networkClient: NetworkClientProtocol
    private let localStorage: any LocalStorageProtocol<Category>

    init(networkClient: NetworkClientProtocol = NetworkClient(), localStorage: any LocalStorageProtocol<Category>) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }

    func getCategories() async throws -> [Category] {
        do {
            let endpoint = CategoriesEndpoint.getAllCategories
            let dtos: [CategoryDTO] = try await networkClient.request(endpoint)
            let categories = ModelMapper.map(dtos)

            // Clear existing categories and save new ones
            try await localStorage.clear()
            for category in categories {
                try await localStorage.create(category)
            }
            NetworkMonitor.shared.setOfflineMode(false)

            return categories
        } catch {
            print("CategoriesService.getCategories failed: \(error)")
            if let networkError = error as? NetworkError {
                switch networkError {
                case .invalidRequest, .invalidResponse, .noData, .decodingError:
                    print("Setting offline mode due to network error: \(networkError)")
                    NetworkMonitor.shared.setOfflineMode(true)
                case .httpError(let statusCode, _, _):
                    print("HTTP error with status code: \(statusCode)")
                    if statusCode >= 500 {
                        NetworkMonitor.shared.setOfflineMode(true)
                    } else {
                        NetworkMonitor.shared.setOfflineMode(false)
                    }
                }
            } else if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled, retrying...")
                throw error
            } else {
                print("Setting offline mode due to unknown error: \(error)")
                NetworkMonitor.shared.setOfflineMode(true)
            }
            return try await localStorage.getAll()
        }
    }

    func getCategoriesDyDirection(direction: Direction) async throws -> [Category] {
        do {
            let endpoint = CategoriesEndpoint.getCategoriesByDirection(direction: direction)
            let dtos: [CategoryDTO] = try await networkClient.request(endpoint)
            let categories = ModelMapper.map(dtos)

            // Clear existing categories and save new ones
            try await localStorage.clear()
            for category in categories {
                try await localStorage.create(category)
            }
            NetworkMonitor.shared.setOfflineMode(false)

            return categories
        } catch {
            print("CategoriesService.getCategoriesDyDirection failed: \(error)")
            if let networkError = error as? NetworkError {
                switch networkError {
                case .invalidRequest, .invalidResponse, .noData, .decodingError:
                    print("Setting offline mode due to network error: \(networkError)")
                    NetworkMonitor.shared.setOfflineMode(true)
                case .httpError(let statusCode, _, _):
                    print("HTTP error with status code: \(statusCode)")
                    if statusCode >= 500 {
                        NetworkMonitor.shared.setOfflineMode(true)
                    } else {
                        NetworkMonitor.shared.setOfflineMode(false)
                    }
                }
            } else if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled, retrying...")
                throw error
            } else {
                print("Setting offline mode due to unknown error: \(error)")
                NetworkMonitor.shared.setOfflineMode(true)
            }
            let allCategories = try await localStorage.getAll()
            return allCategories.filter { $0.direction == direction }
        }
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
