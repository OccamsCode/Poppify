//
//    Resource.swift
//    Poppify
//
//    Created by Brian Munjoma on 21/08/2023.
//
//    Copyright (c) 2023 Brian Munjoma
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

/// A generic value which encapsulates the concept of a resource.
/// It contains a request and a decoding closure
public struct Resource<T> {
    
    /// A  value which conforms to the `Requestable` protocol
    let request: Requestable
    
    /// A closure which is used to decode the response data
    let decode: (Data) throws -> T
    
    /// Creates a `Resource` object
    /// - Parameters:
    ///   - request: The request used to fetch the resource
    ///   - decode: The action used the decode the response into an usable object
    init(request: Requestable, decode: @escaping (Data) throws -> T) {
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
