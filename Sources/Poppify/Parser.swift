//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

import Foundation

public enum ParserError: Error {
    case jsonDecodeError

    var localizedDescription: String {
        switch self {
        case .jsonDecodeError: return "JSON Decoding Error"
        }
    }
}

public protocol Parser {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get set }
    func parse<T>(_ data: Data,
                  into type: T.Type) throws -> T where T: Decodable
    func parse<T>(_ data: Data,
                  into type: T.Type,
                  completion: @escaping (Result<T, ParserError>) -> Void) where T: Decodable
}

public class JSONParser: Parser {

    let decoder: JSONDecoder
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

    init(_ dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) {
        self.decoder = JSONDecoder()
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
