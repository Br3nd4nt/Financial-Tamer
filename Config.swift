//
//  Config 2.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 19.07.2025.
//


import Foundation

enum Config {
    static let bearerToken = "YOUR_BEARER_TOKEN_HERE"
    
    static let baseURL = "https://shmr-finance.ru/api"
    
    static let apiVersion = "v1"
     
    static var apiBaseURL: URL {
        return URL(string: "\(baseURL)/\(apiVersion)")!
    }
} 
