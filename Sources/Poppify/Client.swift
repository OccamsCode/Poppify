//
//    Client.swift
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
import Combine

/// A type which implements the `resume()` function
public protocol URLSessionTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionTaskType {}

/// A protocol representing a type that can perform URL session tasks.
public protocol URLSessionType {
    /// Creates a data task with the specified request and completion handler.
    ///
    /// - Parameters:
    ///   - request: The URL request to be used in the data task.
    ///   - completion: The completion handler to be called when the data task completes.
    /// - Returns: A task representing the ongoing data task.
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType

    /// Asynchronously sends a request and retrieves the data and response.
    ///
    /// - Parameters:
    ///   - request: The URL request to be sent.
    /// - Returns: A tuple containing the received data and the URL response.
    /// - Throws: An error if the request or response processing encounters an issue.
    ///
    /// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and later.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendRequest(for request: URLRequest) async throws -> (Data, URLResponse)

    /// Creates a Combine publisher for a request, allowing for asynchronous handling of the response.
    ///
    /// - Parameters:
    ///   - request: The URL request to be used in the data task publisher.
    /// - Returns: A Combine publisher for the data task.
    ///
    /// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and later.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendPublisherRequest(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}


extension URLSession: URLSessionType {
    public func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType {
        return self.dataTask(with: request, completionHandler: completion)
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sendRequest(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await self.data(for: request)
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sendPublisherRequest(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

/// Encapsulates various types of errors encounters when executing a request
public enum RequestError: Error {
    /// Uable to create a valid request
    case invalidRequest
    
    /// The `Data?` object was nil
    case invalidData
    
    /// The `response` object was not a `HTTPResponse` type
    case invalidResponse
    
    /// Status code was not in the 2xx range
    case unhandledStatusCode(Int)
    
    /// The requested errored with the given error
    case response(error: Error)
    
    /// The decoding failed with the given error
    case decode(error: Error)
}

extension RequestError: Equatable {
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData),
            (.invalidResponse, .invalidResponse),
            (.unhandledStatusCode(_), .unhandledStatusCode(_)),
            (.response(_), .response(_)),
            (.decode(_), .decode(_)):
            return true
        default: return false
        }
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return NSLocalizedString("Invalid Data", comment: "No data sent")                                           // No data sent
        case .invalidResponse:
            return NSLocalizedString("Invalid Response", comment: "URLResponse not HTTPURLResponse")                    // URLResponse not HTTPURLResponse
        case .unhandledStatusCode(let code):
            return NSLocalizedString("Invalid Response StatusCode \(code)" , comment: "Status Code not 2xx")            // Status Code not 2xx
        case .response(let error):
            return NSLocalizedString("Response Error \(error.localizedDescription)", comment: "Error from Request")     // Error from Request
        case .decode(let error):
            return NSLocalizedString("Decode Error \(error.localizedDescription)" , comment: "Error from Decoder")      // Error from Decoder
        case .invalidRequest:
            return NSLocalizedString("Unable to create valid request for resource in environment", comment: "Error during request creation")
        }
    }
}

/// Defines what a `Client` should contain.
///
/// A client should contain the following;
/// - An object which conforms to `EnvironmentType`
/// - An object which conforms to `URLSessionType`
public protocol Client {
    
    /// The environment from which the request is created inside
    var environment: EnvironmentType { get }
    
    /// The session which the request is executed in
    var urlSession: URLSessionType { get }
    
    /// Creates an object which conforms to `URLSessionTaskType` using a `Resource` and completion handler.
    ///
    /// By returning an object, the receiver has can dictate when the operation begins
    /// - Parameters:
    ///   - resource: The resource used to create the request
    ///   - completion: The completion handler to be executed following the execution of the request
    /// - Returns: An object which conforms to `URLSessionTaskType`
    func executeRequest<T>(with resource: Resource<T>,
                     completion: @escaping (Result<T, RequestError>) -> Void ) -> URLSessionTaskType? where T: Decodable
    
    /// Retrieves the contents for a resource and delivers the data asynchronously.
    ///
    /// - Parameter resource: The resource used to create the request
    /// - Returns: An asynchronously-delivered `Result` containing the parsed contents for the resource or `RequestError`
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func executeRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError> where T: Decodable {
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func executeRequestPublisher<T>(with resource: Resource<T>) -> AnyPublisher<T, RequestError> where T: Decodable
    
}

public extension Client {
    
    /// Executes a network request with the specified resource using a completion handler.
    ///
    /// - Parameters:
    ///   - resource: The resource representing the network request to be executed.
    ///   - completion: The completion handler to be called with the result of the network request.
    /// - Returns: A task representing the ongoing network request, or `nil` if the request couldn't be initiated.
    ///
    /// Example usage:
    /// ```swift
    /// let task = apiClient.executeRequest(with: userResource) { result in
    ///     switch result {
    ///     case .success(let user):
    ///         // Handle successful result
    ///         print("Received user: \(user)")
    ///     case .failure(let error):
    ///         // Handle error
    ///         print("Request failed with error: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Note: The generic type `T` must conform to `Decodable`.
    /// - Note: The `completion` handler is called on the main thread.
    ///
    /// - Important: The resource should be configured with the necessary details, such as the URL and HTTP method.
    ///              Ensure that the necessary permissions and capabilities are set for network requests.
    ///
    /// - Returns: A task representing the ongoing network request, or `nil` if the request couldn't be initiated.
    func executeRequest<T>(with resource: Resource<T>,
                     completion: @escaping (Result<T, RequestError>) -> Void ) -> URLSessionTaskType? where T: Decodable {

        guard let urlRequest = URLRequest(request: resource.request,
                                         in: environment) else { return nil }

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in

            if let error = error {
                return completion(.failure(.response(error: error)))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.invalidResponse))
            }
            
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200...299:
                guard let data = data else { return completion(.failure(.invalidData)) }
                do {
                    let decoded = try resource.decode(data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decode(error: error)))
                }
            default:
                completion(.failure(.unhandledStatusCode(statusCode)))
            }

        }
        return task
    }
    
    /// Executes an asynchronous network request with the specified resource and returns the result.
    ///
    /// - Parameters:
    ///   - resource: The resource representing the network request to be executed.
    /// - Returns: A result containing the decoded response or an error.
    ///
    /// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and later.
    /// - Note: The generic type `T` must conform to `Decodable`.
    ///
    /// Example usage:
    /// ```swift
    /// do {
    ///     let result = try await apiClient.executeRequest(with: userResource)
    ///     switch result {
    ///     case .success(let user):
    ///         // Handle successful result
    ///         print("Received user: \(user)")
    ///     case .failure(let error):
    ///         // Handle error
    ///         print("Request failed with error: \(error)")
    ///     }
    /// } catch {
    ///     // Handle asynchronous error
    ///     print("Async error: \(error)")
    /// }
    /// ```
    ///
    /// - Important: The resource should be configured with the necessary details, such as the URL and HTTP method.
    ///              Ensure that the necessary permissions and capabilities are set for network requests.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func executeRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError> where T: Decodable {
        
        guard let urlRequest = URLRequest(request: resource.request,
                                          in: environment) else { return .failure(.invalidRequest) }
        
        do {
            let (data, response) = try await urlSession.sendRequest(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200...299:
                let decodedResponse = try resource.decode(data)
                return .success(decodedResponse)
            default:
                return .failure(.unhandledStatusCode(statusCode))
            }
        } catch let error as DecodingError {
            return .failure(.decode(error: error))
        } catch {
            return .failure(.response(error: error))
        }
    }
    
    /// Executes a network request with the specified resource and returns a Combine publisher.
    ///
    /// - Parameters:
    ///   - resource: The resource representing the network request to be executed.
    /// - Returns: A Combine publisher that emits the result of the network request or an error.
    ///
    /// - Note: This function is only available on macOS 10.15, iOS 13.0, watchOS 6.0, and tvOS 13.0, and
    /// - Note: The generic type `T` must conform to `Decodable`.
    ///
    /// Example usage:
    /// ```swift
    /// cancellable = apiClient.executeRequest(with: userResource)
    ///     .sink(
    ///         receiveCompletion: { completion in
    ///             switch completion {
    ///             case .finished:
    ///                 // Handle completion
    ///                 break
    ///             case .failure(let error):
    ///                 // Handle error
    ///                 break
    ///             }
    ///         },
    ///         receiveValue: { user in
    ///             // Handle successful result
    ///             print("Received user: \(user)")
    ///         }
    ///     )
    /// ```
    ///
    /// - Important: The resource should be configured with the necessary details, such as the URL and HTTP method.
    ///              Ensure that the necessary permissions and capabilities are set for network requests.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func executeRequestPublisher<T>(with resource: Resource<T>) -> AnyPublisher<T, RequestError> where T: Decodable {

            guard let urlRequest = URLRequest(request: resource.request,
                                              in: environment) else {
                return Fail(error: RequestError.invalidRequest)
                    .eraseToAnyPublisher()
            }
            
            return urlSession.sendPublisherRequest(for: urlRequest)
                .tryMap { (data, response) -> T in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw RequestError.invalidResponse
                    }
                    
                    let statusCode = httpResponse.statusCode
                    switch statusCode {
                    case 200...299:
                        return try resource.decode(data)
                    default:
                        throw RequestError.unhandledStatusCode(statusCode)
                    }
                }
                .mapError {
                    RequestError.response(error: $0)
                }
                .eraseToAnyPublisher()
            
        }
}
