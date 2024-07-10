//
//    HTTP.swift
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

/// Represents a set of conception related to a HTTP request.
public enum HTTP {

    /// This is a namespace for the HTTP Header keys & values.
    public enum Header {

        /// Represents a the concept of a HTTP Header Key
        ///
        /// Conforms to `ExpressibleByStringLiteral`, hence can be expressed using a string
        ///
        ///     let accept: HTTP.Header.Key = "Accept"
        ///
        public struct Key: ExpressibleByStringLiteral {
            let rawValue: String
            
            /// Creates a HTTP Header Key with the given value.
            ///
            /// - Parameter value: The string used for the HTTP Header Key
            public init(stringLiteral value: String) {
                self.rawValue = value
            }
        }
        
        /// Represents a the concept of a HTTP Header Value
        ///
        /// Conforms to `ExpressibleByStringLiteral`, hence can be expressed using a string
        ///
        ///     let accept: HTTP.Header.Value = "application/json"
        ///
        public struct Value: ExpressibleByStringLiteral {
            let rawValue: String
            
            /// Creates a HTTP Header Value with the given value.
            ///
            /// - Parameter value: The string used for the HTTP Header Value
            public init(stringLiteral value: String) {
                self.rawValue = value
            }
        }
    }
    
    /// A namespace for the security of the HTTP request.
    ///
    /// - `secure`: secure connections via HTTPS.
    /// - `unsecure`: unsecure connections via HTTP.
    public enum Scheme: String {
        /// secure connections/HTTPS.
        case secure = "https"
        ///  unsecure connections/HTTP.
        case unsecure = "http"
    }
    
    /// A namespace for the various types of HTTP methods possible
    ///
    ///  For more information, see [HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
    public enum Method: String {
        
        /// The `GET` method requests a representation of the specified resource. Requests using `GET` should only retrieve data.
        case GET
        
        /// The `HEAD` method asks for a response identical to that of a `GET` request, but without the response body.
        case HEAD
        
        /// The `POST` method submits an entity to the specified resource, often causing a change in state or side effects on the server.
        case POST
        
        /// The `PUT` method replaces all current representations of the target resource with the request payload.
        case PUT
        
        /// The `DELETE` method deletes the specified resource.
        case DELETE
        
        /// The `PATCH` method applies partial modifications to a resource.
        case PATCH
    }
}
