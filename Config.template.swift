//
//  Config.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 23.07.2025.
//

import Foundation

// Rename the enum to "Config" and input your token

// swiftlint:disable all
enum Config_template {
    static let bearerToken = "YOUR_API_KEY_HERE"
    
    static let baseURL = "https://shmr-finance.ru/api"
    
    static let apiVersion = "v1"
     
    static var apiBaseURL: URL {
        return URL(string: "\(baseURL)/\(apiVersion)")!
    }
} 
// swiftlint:enable all 
