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

/// A type which implements the `resume()` function
public protocol URLSessionTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionTaskType {}

/// A type which implements requests with completion handlers & async await
public protocol URLSessionType {
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendRequest(for request: URLRequest) async throws -> (Data, URLResponse)
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
}

/// Encapsulates various types of errors encounters when executing a request
public enum RequestError: Error, Equatable {

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
    
    var localizedDescription: String {
        switch self {
        case .invalidData: return "Invalid Data"                                            // No data sent
        case .invalidResponse: return "Invalid Response"                                    // URLResponse not HTTPURLResponse
        case .unhandledStatusCode(let code): return "Invalid Response StatusCode \(code)"   // Status Code not 2xx
        case .response(let error): return "Response Error \(error)"                         // Error from Request
        case .decode(let error): return "Decode Error \(error)"                             // Error from Decoder
        case .invalidRequest:
            return "Unable to create valid request for resource in environment"
        }
    }

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
    func dataTask<T>(with resource: Resource<T>,
                     completion: @escaping (Result<T, RequestError>) -> Void ) -> URLSessionTaskType? where T: Decodable
    
    /// Retrieves the contents for a resource and delivers the data asynchronously.
    ///
    /// - Parameter resource: The resource used to create the request
    /// - Returns: An asynchronously-delivered `Result` containing the parsed contents for the resource or `RequestError`
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError>
}

public extension Client {
    func dataTask<T>(with resource: Resource<T>,
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
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError> {
        
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
}
