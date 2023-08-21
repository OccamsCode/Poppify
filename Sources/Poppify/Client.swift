//
//  File.swift
//  
//
//  Created by Brian Munjoma on 21/08/2023.
//

import Foundation

public protocol URLSessionTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionTaskType {}

public protocol URLSessionType {
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType
    
    @available(iOS 13.0.0, *)
    func sendRequest(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionType {
    public func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType {
        return self.dataTask(with: request, completionHandler: completion)
    }
    
    @available(iOS 13.0.0, *)
    public func sendRequest(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await self.data(for: request)
    }
}

public enum RequestError: Error, Equatable {

    case invalidData
    case invalidResponse
    case unhandledStatusCode(Int)
    case response(error: Error)
    case decode(error: Error)

    var localizedDescription: String {
        switch self {
        case .invalidData: return "Invalid Data"                                            // No data sent
        case .invalidResponse: return "Invalid Response"                                    // URLResponse not HTTPURLResponse
        case .unhandledStatusCode(let code): return "Invalid Response StatusCode \(code)"   // Status Code not 2xx
        case .response(let error): return "Response Error \(error)"                         // Error from Request
        case .decode(let error): return "Decode Error \(error)"                             // Error from Decoder
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

public protocol Client {

    var environment: EnvironmentType { get }
    var urlSession: URLSessionType { get }

    func dataTask<T>(with resource: Resource<T>,
                     completion: @escaping (Result<T, RequestError>) -> Void ) -> URLSessionTaskType? where T: Decodable
    
    @available(iOS 13.0.0, *)
    func sendRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError>?
}

public extension Client {
    func dataTask<T>(with resource: Resource<T>,
                     completion: @escaping (Result<T, RequestError>) -> Void ) -> URLSessionTaskType? where T: Decodable {

        guard let urlReqest = URLRequest(request: resource.request,
                                         in: environment) else { return nil }

        let task = urlSession.dataTask(with: urlReqest) { data, response, error in

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
    
    @available(iOS 13.0.0, *)
    func sendRequest<T>(with resource: Resource<T>) async -> Result<T, RequestError>? {
        
        guard let urlReqest = URLRequest(request: resource.request,
                                         in: environment) else { return nil }
        
        do {
            let (data, response) = try await urlSession.sendRequest(for: urlReqest)
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
        } catch {
            return .failure(.decode(error: error))
        }
    }
}
