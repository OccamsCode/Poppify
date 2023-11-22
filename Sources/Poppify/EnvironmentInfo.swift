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

/// A value that represents a request secret either as a query item or in a HTTP header
public enum Secret {
    
    /// A secret stored in a URL query item
    case queryItem(_ item: URLQueryItem)
    
    /// A secret stored in a HTTP header
    case header(_ key: HTTP.Header.Key, value: HTTP.Header.Value)
}

/// A type which represents the core values of an environment from which requests can be created within
public protocol EnvironmentType {
    
    /// The scheme which the request will use
    var scheme: HTTP.Scheme { get }
    
    /// The base endpoint used for the environment
    var endpoint: String { get }
    
    /// Any additional headers to be sent in the request
    var additionalHeaders: [String: String] { get }
    
    /// An optional port number for the request
    var port: Int? { get }
    
    /// An optional secret used for the request
    var secret: Secret? { get }
}


/// A simple value which conforms to `EnvironmentType` and contains a `debugDescription` for debugging purposes.
public struct EnvironmentInfo: EnvironmentType, CustomDebugStringConvertible {

    public let scheme: HTTP.Scheme
    public let endpoint: String
    public let additionalHeaders: [String: String]
    public let port: Int?
    public let secret: Secret?

    public init(scheme: HTTP.Scheme,
                endpoint: String,
                additionalHeaders: [String : String] = [:],
                port: Int? = nil,
                secret: Secret? = nil) {
        self.scheme = scheme
        self.endpoint = endpoint
        self.additionalHeaders = additionalHeaders
        self.port = port
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

/// A simple value which conforms to `EnvironmentType` and contains a `debugDescription` for debugging purposes.
@available(*, deprecated, renamed: "EnvironmentInfo")
public struct Environment: EnvironmentType, CustomDebugStringConvertible {

    public let scheme: HTTP.Scheme
    public let endpoint: String
    public let additionalHeaders: [String: String]
    public let port: Int?
    public let secret: Secret?

    public init(scheme: HTTP.Scheme,
                endpoint: String,
                additionalHeaders: [String : String] = [:],
                port: Int? = nil,
                secret: Secret? = nil) {
        self.scheme = scheme
        self.endpoint = endpoint
        self.additionalHeaders = additionalHeaders
        self.port = port
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
