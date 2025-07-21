//
//  RequestBuilderProtocol.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 18.07.2025.
//

import Foundation

protocol RequestBuilderProtocol {
    func buildRequest<T: Encodable>(from endpoint: Endpoint, body: T?) async -> URLRequest?
}
