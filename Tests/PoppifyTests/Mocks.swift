//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

import Foundation
@testable import Poppify

struct MockModel: Decodable {
    let name: String
    let age: Int
    let isDone: Bool
}

// MARK: - Requestable Tests
struct MockDefaultRequest: Requestable {
    let path: String
}

struct MockCustomRequest: Requestable {
    let path: String
    var method: HTTP.Method { .POST }
    var parameters: [URLQueryItem] { return [URLQueryItem(name: "name", value: "value")] }
    var headers: [String: String] { return ["Content-Length": "348"] }
    var body: Data? { return Data() }
}
