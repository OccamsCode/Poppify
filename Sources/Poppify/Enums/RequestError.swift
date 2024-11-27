//
//    RequestError.swift
//    Poppify
//
//    Created by Brian Munjoma on 15/11/2024.
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

/// Encapsulates various types of errors encounters when executing a request
public enum RequestError: Error {
    /// Uable to create a valid request
    case invalidRequest
    
    /// The `Data?` object was nil
    case invalidData
    
    /// The `response` object was not a `HTTPResponse` type
    case invalidResponse
    
    /// Status code was not in the 2xx range
    case unhandledStatusCode(Int)
    
    /// The requested errored with the given error
    case response(error: Error)
    
    /// The decoding failed with the given error
    case decode(error: Error)
}

extension RequestError: Equatable {
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData),
            (.invalidResponse, .invalidResponse),
            (.unhandledStatusCode(_), .unhandledStatusCode(_)),
            (.response(_), .response(_)),
            (.decode(_), .decode(_)):
            return true
        default: return false
        }
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return NSLocalizedString("Invalid Data", comment: "No data sent")                                           // No data sent
        case .invalidResponse:
            return NSLocalizedString("Invalid Response", comment: "URLResponse not HTTPURLResponse")                    // URLResponse not HTTPURLResponse
        case .unhandledStatusCode(let code):
            return NSLocalizedString("Invalid Response StatusCode \(code)" , comment: "Status Code not 2xx")            // Status Code not 2xx
        case .response(let error):
            return NSLocalizedString("Response Error \(error.localizedDescription)", comment: "Error from Request")     // Error from Request
        case .decode(let error):
            return NSLocalizedString("Decode Error \(error.localizedDescription)" , comment: "Error from Decoder")      // Error from Decoder
        case .invalidRequest:
            return NSLocalizedString("Unable to create valid request for resource in environment", comment: "Error during request creation")
        }
    }
}
