//
//    EnvironmentInfo.swift
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

/// A simple value which conforms to `EnvironmentType` and contains a `debugDescription` for debugging purposes.
public struct EnvironmentInfo: EnvironmentType, CustomDebugStringConvertible {

    public let scheme: HTTP.Scheme
    public let endpoint: String
    public let additionalHeaders: [String: String]
    public let port: Int?
    public let basePath: String?
    public let secret: Secret?

    public init(scheme: HTTP.Scheme,
                endpoint: String,
                additionalHeaders: [String : String] = [:],
                port: Int? = nil,
                basePath: String? = nil,
                secret: Secret? = nil) {
        self.scheme = scheme
        self.endpoint = endpoint
        self.additionalHeaders = additionalHeaders
        self.port = port
        self.basePath = basePath
        self.secret = secret
    }
    
    /// A textual representation of this instance, suitable for debugging.
    ///
    /// The values for `additionalHeaders` and `secret` are purposely omitted
    public var debugDescription: String {
        var components = ["\(scheme.rawValue)-\(endpoint)"]
        if let port = port { components.append(":\(port)") }
        if let basePath = basePath { components.append("/\(basePath)") }
        return components.joined()
    }
}

/// A simple value which conforms to `EnvironmentType` and contains a `debugDescription` for debugging purposes.
@available(*, unavailable, renamed: "EnvironmentInfo")
public struct Environment: EnvironmentType, CustomDebugStringConvertible {

    public let scheme: HTTP.Scheme
    public let endpoint: String
    public let additionalHeaders: [String: String]
    public let port: Int?
    public let basePath: String?
    public let secret: Secret?

    public init(scheme: HTTP.Scheme,
                endpoint: String,
                additionalHeaders: [String : String] = [:],
                port: Int? = nil,
                basePath: String? = nil,
                secret: Secret? = nil) {
        self.scheme = scheme
        self.endpoint = endpoint
        self.additionalHeaders = additionalHeaders
        self.port = port
        self.basePath = basePath
        self.secret = secret
    }
    
    /// A textual representation of this instance, suitable for debugging.
    ///
    /// The values for `additionalHeaders` and `secret` are purposely omitted
    public var debugDescription: String {
        var output = "\(scheme.rawValue)-\(endpoint)"
        if let port = port {
            output += ":\(port)"
        }
        return output
    }
}
