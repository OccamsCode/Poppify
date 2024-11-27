//
//    HTTPResponseMapper.swift
//    Poppify
//
//    Created by Brian Munjoma on 27/11/2024.
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

public enum HTTPResponseMapper {
    /// Maps an HTTP response to a decoded object of type `T`.
    ///
    /// - Parameters:
    ///   - data: The raw data returned by the HTTP request.
    ///   - response: The HTTP response metadata, including the status code and headers.
    /// - Returns: A decoded object of type `T`.
    /// - Throws:
    ///   - `RequestError.decode` if there is an issue decoding the data.
    ///   - `RequestError.unhandledStatusCode` for non-successful HTTP status codes.
    public static func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
            do {
                let parser = JSONParser()
                return try parser.parse(data, into: T.self)
            } catch {
                throw RequestError.decode(error: error)
            }
        default:
            throw RequestError.unhandledStatusCode(statusCode)
        }
    }
}

