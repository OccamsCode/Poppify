//
//    URLRequest+Extension.swift
//    Poppify
//
//    Created by Brian Munjoma on 18/11/2024.
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

public extension URLRequest {

    /// Initializes a newly created URLRequest using the contents of the given request, relative to a given environment.
    /// - Parameters:
    ///   - request: The request used to create the URL and supply request-specific headers and body.
    ///   - environment: The environment used to construct the base URL, additional headers, and optional secret.
    ///   - headerPrecedence: Determines which source wins when `request.headers` and
    ///     `environment.additionalHeaders` share the same key. Defaults to `.environmentOverRequest`.
    ///
    /// The `environment.secret` header, if present, is always applied last and takes the highest priority
    /// regardless of `headerPrecedence`.
    ///
    /// Header application order:
    /// - `.environmentOverRequest`: request headers → environment headers → secret
    /// - `.requestOverEnvironment`: environment headers → request headers → secret
    init?(request: Requestable, in environment: EnvironmentType, headerPrecedence: HeaderPrecedence = .environmentOverRequest) {

        guard let fullURL = request.url(using: environment) else { return nil }
        self.init(url: fullURL)
        self.httpMethod = request.method.rawValue

        switch headerPrecedence {
        case .environmentOverRequest:
            request.headers.forEach { self.setValue($0.value, forHTTPHeaderField: $0.key) }
            environment.additionalHeaders.forEach { self.setValue($0.value, forHTTPHeaderField: $0.key) }
        case .requestOverEnvironment:
            environment.additionalHeaders.forEach { self.setValue($0.value, forHTTPHeaderField: $0.key) }
            request.headers.forEach { self.setValue($0.value, forHTTPHeaderField: $0.key) }
        }

        if case let .header(key, value) = environment.secret {
            self.setValue(value.rawValue, forHTTPHeaderField: key.rawValue)
        }

        self.httpBody = request.body
    }
}
