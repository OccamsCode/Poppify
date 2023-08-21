//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

import Foundation

public struct Resource<T> {
    let request: Requestable
    let decode: (Data) throws -> T
    
    init(request: Requestable, decode: @escaping (Data) throws -> T) {
        self.request = request
        self.decode = decode
    }
}

public extension Resource where T: Decodable {
    init(request: Requestable) {
        self.init(request: request) { data in
            do {
                let parser = JSONParser()
                return try parser.parse(data, into: T.self)
            } catch {
                throw error
            }
        }
    }
}
