//
//    Requestable.swift
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

/// A type that is used the create a `URLRequest` with a given environment
public protocol Requestable: CustomDebugStringConvertible {
    
    /// The HTTP method used in the request
    ///
    /// When not specified, defaults to `GET`
    var method: HTTP.Method { get }
    
    /// The path in the environment
    var path: String { get }
    
    /// The parameters used in the request
    ///
    /// When not specified, defaults to an empty array
    ///
    ///     var parameters { return [] }
    var parameters: [URLQueryItem] { get }
    
    /// The headers specific to the request
    ///
    /// When not specified, defaults to an empty dictionary
    ///
    ///     var headers { return [:] }
    var headers: [String: String] { get }
    
    /// The optional body for the request
    ///
    /// When not specified, defaults to `nil`
    ///
    ///     var body { return nil }
    var body: Data? { get }
}

public extension Requestable {
    var method: HTTP.Method { .GET }
    var parameters: [URLQueryItem] { return [] }
    var headers: [String: String] { return [:] }
    var body: Data? { return nil }
    
    /// Attempts to create URL for the `Requestable` object, within the given environment
    /// - Parameter environment: The environment used to create the URL
    /// - Returns: A valid URL object if the `Requestable` and `EnvironmentType` contain the correct values, otherwise returns `nil`
    ///
    /// The `environment.secret` is added if it's a query item
    func url(using environment: EnvironmentType) -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = environment.scheme.rawValue
        urlComponents.host = environment.endpoint
        urlComponents.port = environment.port
        urlComponents.path = path
        urlComponents.queryItems = parameters

        if case let .queryItem(item) = environment.secret {
            urlComponents.queryItems?.append(item)
        }

        return urlComponents.url
    }

    var debugDescription: String {
        return """

        ⌜--------------------
        Request: \(method) - \(path)
        Headers: \(headers.sorted(by: <).reduce("", { $0 + "\($1.key): \($1.value)," }))
        Date: \(Date())
        Parameters: \(parameters)
        ⌞--------------------
        """
    }

}

public extension URLRequest {
    
    /// Initializes a newly created URLRequest using the contents of the given request, relative to a given environment.
    /// - Parameters:
    ///   - request: The request used to create the URL for the URLRequest
    ///   - environment: The environment used to create the URL and fill the relevant fields of the URLRequest
    init?(request: Requestable, in environment: EnvironmentType) {

        guard let fullURL = request.url(using: environment) else { return nil }
        self.init(url: fullURL)
        self.httpMethod = request.method.rawValue

        request.headers.forEach { (key, value) in
            self.setValue(value, forHTTPHeaderField: key)
        }

        environment.additionalHeaders.forEach { (key, value) in
            self.setValue(value, forHTTPHeaderField: key)
        }

        if case let .header(key, value) = environment.secret {
            self.setValue(value.rawValue, forHTTPHeaderField: key.rawValue)
        }
        
        self.httpBody = request.body
    }
}
