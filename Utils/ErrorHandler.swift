//
//  ErrorHandler.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation
import SwiftUI

final class ErrorHandler: ObservableObject {
    @Published var currentError: ErrorInfo?

    private let verboseLogging = true

    struct ErrorInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let error: Error
        let context: String
    }

    func handleError(_ error: Error, context: String, userMessage: String? = nil) {
        if verboseLogging {
            print("❌ ERROR in \(context):")
            print("   Error type: \(type(of: error))")
            print("   Error description: \(error.localizedDescription)")
            print("   Full error: \(error)")
        }

        let errorInfo = ErrorInfo(
            title: "Ошибка",
            message: userMessage ?? getDefaultErrorMessage(for: error),
            error: error,
            context: context
        )

        DispatchQueue.main.async {
            self.currentError = errorInfo
        }
    }

    func handleNetworkError(_ error: Error, context: String, url: URL? = nil, responseBody: String? = nil) {
        if verboseLogging {
            print("❌ NETWORK ERROR in \(context):")
            print("   Error type: \(type(of: error))")
            print("   Error description: \(error.localizedDescription)")
            if let url { print("   Request URL: \(url)") }
            if let responseBody { print("   Response body: \(responseBody)") }
            print("   Full error: \(error)")
        }
        let userMessage = getNetworkErrorMessage(for: error)
        handleError(error, context: context, userMessage: userMessage)
    }

    func handleServiceError(_ error: Error, context: String, serviceName: String, url: URL? = nil, responseBody: String? = nil) {
        let userMessage = "Не удалось загрузить \(serviceName). Пожалуйста, попробуйте позже."
        var errorUrl = url
        var errorResponseBody = responseBody

        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(_, let url, let responseBody):
                errorUrl = url
                errorResponseBody = responseBody
            case .decodingError(let url, let responseBody, _):
                errorUrl = url
                errorResponseBody = responseBody
            default:
                break
            }
        }
        if verboseLogging {
            print("❌ SERVICE ERROR in \(context):")
            print("   Service: \(serviceName)")
            print("   Error type: \(type(of: error))")
            print("   Error description: \(error.localizedDescription)")
            if let url = errorUrl { print("   Request URL: \(url)") }
            if let responseBody = errorResponseBody { print("   Response body: \(responseBody)") }
            print("   Full error: \(error)")
        }
        handleError(error, context: context, userMessage: userMessage)
    }

    private func getDefaultErrorMessage(for error: Error) -> String {
        "Произошла ошибка: \(error.localizedDescription)"
    }

    private func getNetworkErrorMessage(for error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidRequest:
                return "Неверный запрос к серверу"
            case .invalidResponse:
                return "Неверный ответ от сервера"
            case .noData:
                return "Сервер не вернул данные"
            case .httpError(let statusCode, _, _):
                switch statusCode {
                case 400:
                    return "Неверный запрос"
                case 401:
                    return "Необходима авторизация"
                case 403:
                    return "Доступ запрещен"
                case 404:
                    return "Ресурс не найден"
                case 500:
                    return "Ошибка сервера"
                default:
                    return "Ошибка сети (код \(statusCode))"
                }
            case .decodingError:
                return "Ошибка обработки данных"
            }
        }
        return "Ошибка сети: \(error.localizedDescription)"
    }
}

extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        self.alert(
            errorHandler.currentError?.title ?? "Ошибка",
            isPresented: Binding(
                get: { errorHandler.currentError != nil },
                set: { if !$0 { errorHandler.currentError = nil } }
            )
        ) {
            Button("OK") {
                errorHandler.currentError = nil
            }
        } message: {
            if let error = errorHandler.currentError {
                Text(error.message)
            }
        }
    }
}
