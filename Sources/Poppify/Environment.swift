//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

import Foundation

public enum Secret {
    case queryItem(_ item: URLQueryItem)
    case header(_ key: HTTP.Header.Key, value: HTTP.Header.Value)
}

public protocol EnvironmentType {
    var scheme: HTTP.Scheme { get }
    var endpoint: String { get }
    var addtionalHeaders: [String: String] { get }
    var port: Int? { get }
    var secret: Secret? { get }
}

public struct Environment: EnvironmentType, CustomStringConvertible {

    public let scheme: HTTP.Scheme
    public let endpoint: String
    public let addtionalHeaders: [String: String]
    public let port: Int?
    public let secret: Secret?

    public init(scheme: HTTP.Scheme, endpoint: String, addtionalHeaders: [String : String], port: Int?, secret: Secret?) {
        self.scheme = scheme
        self.endpoint = endpoint
        self.addtionalHeaders = addtionalHeaders
        self.port = port
        self.secret = secret
    }
    
    public var description: String {
        var output = "\(scheme.rawValue)-\(endpoint)"
        if let port = port {
            output += ":\(port)"
        }
        return output
    }
}
