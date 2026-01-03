//
//  AsyncURLSessionType.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import Foundation

/// A protocol representing a type that can perform URL session tasks.
///
/// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and later.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol AsyncURLSessionType {
    /// Asynchronously sends a request and retrieves the data and response.
    ///
    /// - Parameters:
    ///   - request: The URL request to be sent.
    /// - Returns: A tuple containing the received data and the URL response.
    /// - Throws: An error if the request or response processing encounters an issue.
    func asyncData(for request: URLRequest) async throws -> DataResponse
}
