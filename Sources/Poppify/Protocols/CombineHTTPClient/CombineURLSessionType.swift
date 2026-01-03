//
//  CombineURLSessionType.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import Combine
import Foundation

/// A protocol representing a type that can perform URL session tasks.
///
/// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and later.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol CombineURLSessionType {
    /// Creates a Combine publisher for a request, allowing for asynchronous handling of the response.
    ///
    /// - Parameters:
    ///   - request: The URL request to be used in the data task publisher.
    /// - Returns: A Combine publisher for the data task.
    func sendPublisherRequest(for request: URLRequest) -> AnyPublisher<DataResponse, URLError>
}
