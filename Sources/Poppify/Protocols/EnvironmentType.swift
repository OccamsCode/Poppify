//
//    EnvironmentType.swift
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
    
    /// The base path used for the environment
    var basePath: String? { get }
}
