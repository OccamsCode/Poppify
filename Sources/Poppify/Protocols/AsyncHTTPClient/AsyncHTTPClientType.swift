//
//  AsyncHTTPClientType.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol AsyncHTTPClientType {
    /// The environment in which the HTTP client operates, containing base URLs and other configurations.
    var environment: EnvironmentType { get async }
    
    /// The session in which the request is executed. This session is responsible for managing HTTP tasks and connections.
    var urlSession: AsyncURLSessionType { get }
}
