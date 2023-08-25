//
//    Parser.swift
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

/// Encapsulates an error when decoding a json in to a `Decodable` object
public enum ParserError: Error {
    case jsonDecodeError

    var localizedDescription: String {
        switch self {
        case .jsonDecodeError: return "JSON Decoding Error"
        }
    }
}

/// A type that can decode binary data into objects which conform to `Decodable`
public protocol Parser {
    
    /// The strategy used when decoding the date
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get set }
    
    /// Parses the JSON into an object conforming to `Decodable` and returns it.
    /// - Parameters:
    ///   - data: The  JSON object to be decoded.
    ///   - type: The type of the value to decode from the supplied JSON object.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    func parse<T>(_ data: Data,
                  into type: T.Type) throws -> T where T: Decodable
    
    /// Parses the data into an object conforming to `Decodable` and passing it to the closure.
    /// - Parameters:
    ///   - data: The  JSON object to be decoded.
    ///   - type: The type of the value to decode from the supplied JSON object.
    ///   - completion: A `Result` indicating the decoding was successful or failed.
    func parse<T>(_ data: Data,
                  into type: T.Type,
                  completion: @escaping (Result<T, ParserError>) -> Void) where T: Decodable
}

/// A simple implementation of a JSON parser
public class JSONParser: Parser {
    
    /// The decoder used to decode the JSON object
    let decoder: JSONDecoder
    
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    /// Initializes a parser object to decode the JSON data using a decoder and date decoding strategy
    /// - Parameters:
    ///   - decoder: The decoder used to decode the JSON object
    ///   - dateDecodingStrategy: The strategy used when decoding the date
    init(decoder: JSONDecoder = JSONDecoder(),
         dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) {
        self.decoder = decoder
        self.dateDecodingStrategy = dateDecodingStrategy
    }

    public func parse<T>(_ data: Data,
                  into type: T.Type) throws -> T where T: Decodable {
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(T.self, from: data)
    }

    public func parse<T>(_ data: Data,
                  into type: T.Type,
                  completion: @escaping (Result<T, ParserError>) -> Void) where T: Decodable {
        decoder.dateDecodingStrategy = dateDecodingStrategy
        do {
            let result = try decoder.decode(T.self, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(.jsonDecodeError))
        }
    }

}
