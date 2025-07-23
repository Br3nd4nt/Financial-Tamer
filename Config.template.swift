//
//  Config.template.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//

import Foundation

// swiftlint:disable all
enum Config {
    static let bearerToken = "YOUR_API_KEY_HERE"
    
    static let baseURL = "https://shmr-finance.ru/api"
    
    static let apiVersion = "v1"
     
    static var apiBaseURL: URL {
        return URL(string: "\(baseURL)/\(apiVersion)")!
    }
} 
// swiftlint:enable all 