//
//  AsyncHTTPClient.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol AsyncHTTPClient: AsyncHTTPClientType {
    /// Executes a network request with the specified resource and returns a Combine publisher.
    ///
    /// - Parameters:
    ///   - request: The resource representing the network request to be executed.
    /// - Returns: An HTTPClientResponse containing the result of the network request.
    /// - Throws: An error if the network request fails.
    func asyncRequest(with request: Requestable) async throws -> HTTPClientResponse
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncHTTPClient {
    func asyncRequest(with request: Requestable) async throws -> HTTPClientResponse {
        guard let urlRequest = await URLRequest(request: request, in: environment) else {
            throw RequestError.invalidRequest
        }
        
        let (data, response) = try await urlSession.asyncData(for: urlRequest)
        
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw RequestError.invalidResponse
        }
        return (data, httpURLResponse)
    }
}
