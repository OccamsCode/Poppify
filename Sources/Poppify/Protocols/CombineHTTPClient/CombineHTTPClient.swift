//
//  CombineHTTPClient.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol CombineHTTPClient: CombineHTTPClientType {
    /// Executes a network request with the specified resource and returns a Combine publisher.
    ///
    /// - Parameter request: The resource representing the network request to be executed.
    /// - Returns: A Combine publisher that emits `HTTPClientResponse` on success or an error on failure.
    func publisherRequest(with request: Requestable) -> AnyPublisher<HTTPClientResponse, Error>
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension CombineHTTPClient {
    func publisherRequest(with request: Requestable) -> AnyPublisher<HTTPClientResponse, Error> {
        guard let urlRequest = URLRequest(request: request,
                                          in: environment) else {
            return Fail(error: RequestError.invalidRequest)
                .eraseToAnyPublisher()
        }
        
        return urlSession.sendPublisherRequest(for: urlRequest)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw RequestError.invalidResponse
                }
                
                return (data, httpResponse)
            }
            .mapError {
                RequestError.response(error: $0)
            }
            .eraseToAnyPublisher()
    }
}

