//
//  ParserError.swift
//  Poppify
//
//  Created by Brian Munjoma on 24/07/2025.
//


/// Encapsulates an error when decoding a json in to a `Decodable` object
public enum ParserError: Error {
    case jsonDecodeError(Error)

    var localizedDescription: String {
        switch self {
        case .jsonDecodeError(let error): return "JSON Decoding Error \(error.localizedDescription)"
        }
    }
}

extension ParserError: Equatable {
    public static func == (lhs: ParserError, rhs: ParserError) -> Bool {
        switch (lhs, rhs) {
        case (.jsonDecodeError(_), .jsonDecodeError(_)):
            return true
        }
    }
}
