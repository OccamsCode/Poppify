//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

public enum HTTP {

    public enum Header {

        public struct Key: ExpressibleByStringLiteral {
            let rawValue: String

            public init(stringLiteral value: String) {
                self.rawValue = value
            }
        }

        public struct Value: ExpressibleByStringLiteral {
            let rawValue: String

            public init(stringLiteral value: String) {
                self.rawValue = value
            }
        }
    }

    public enum Scheme: String {
        case secure = "https"
        case unsecure = "http"
    }

    public enum Method: String {
        case GET, POST, PUT, DELETE
    }
}
