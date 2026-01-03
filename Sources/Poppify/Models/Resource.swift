//
//  Resource.swift
//  Poppify
//
//  Created by Brian Munjoma on 24/07/2025.
//

import Foundation


/// A generic value which encapsulates the concept of a resource.
/// It contains a request and a decoding closure
public struct Resource<T> {
    
    /// A  value which conforms to the `Requestable` protocol
    public let request: Requestable
    
    /// A closure which is used to decode the response data
    public let decode: (Data) throws -> T
    
    /// Creates a `Resource` object
    /// - Parameters:
    ///   - request: The request used to fetch the resource
    ///   - decode: The action used the decode the response into an usable object
    public init(request: Requestable, decode: @escaping (Data) throws -> T) {
        self.request = request
        self.decode = decode
    }
}

public extension Resource where T: Decodable {
    
    /// Creates a `Resource` object where the decoding action is set to automatically decode a `Decodable` object
    /// - Parameter request: The request used to fetch the resource
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
