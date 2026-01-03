//
//  Mocks.swift
//  
//
//  Created by Brian Munjoma.
//

@testable import Poppify
import Foundation
import Combine

struct MockModel: Decodable {
    let name: String
    let age: Int
    let isDone: Bool
}

// MARK: - Requestable Tests
struct MockDefaultRequest: Requestable {
    let path: String
}

struct MockCustomRequest: Requestable {
    let path: String
    var method: HTTP.Method { .POST }
    var parameters: [URLQueryItem] { return [URLQueryItem(name: "name", value: "value")] }
    var headers: [String: String] { return ["Content-Length": "348"] }
    var body: Data? { return Data() }
}

// MARK: - Environment
struct MockSecureEnvironment: EnvironmentType {
    var scheme: HTTP.Scheme = .secure
    var endpoint: String = "api.mock.org"
    var additionalHeaders: [String : String] = ["Connection": "Close"]
    var port: Int? = 443
    var basePath: String? = "/test"
    var secret: Secret? = .header("X-API-KEY", value: "c6fb701caa6b1fbe4290a16e77b564b8")
}

struct MockUnsecureEnvironment: EnvironmentType {
    var scheme: HTTP.Scheme = .unsecure
    var endpoint: String = "api.mock.com"
    var additionalHeaders: [String : String] = ["Connection": "Keep-Alive"]
    var port: Int? = 80
    var basePath: String? = "/v1"
    var secret: Secret? = .queryItem(URLQueryItem(name: "API-KEY", value: "Poppify-MD5"))
}

// MARK: - URLSessionTask
final class MockTask: URLSessionTaskType {

    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func resume() {
        closure()
    }
}


final class MockResponse {

    static func create(withCode code: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "www.google.com")!,
                               statusCode: code,
                               httpVersion: nil,
                               headerFields: nil)!
    }

    static func create() -> URLResponse {
        return URLResponse(url: URL(string: "www.google.com")!,
                           mimeType: nil,
                           expectedContentLength: 1,
                           textEncodingName: nil)
    }

}

// MARK: - URLSession
final class MockURLSession {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
}

extension MockURLSession: URLSessionType {
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskType {
        return MockTask {
            completion(self.data, self.response, self.error)
        }
    }
}

extension MockURLSession: CombineURLSessionType {
    @available(iOS 13.0.0, *)
    func sendPublisherRequest(for request: URLRequest) -> AnyPublisher<DataResponse, URLError> {
        if error != nil {
            return Fail(error: URLError(.init(rawValue: 300)))
                .eraseToAnyPublisher()
        }
        
        guard let data = data, let response = response else {
            return Fail(error: URLError(.init(rawValue: 300)))
                .eraseToAnyPublisher()
        }
        return Just((data, response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}

extension MockURLSession: AsyncURLSessionType {
    @available(iOS 13.0.0, *)
    func asyncData(for request: URLRequest) async throws -> DataResponse {
        if let error = error { throw error }
        guard let data = data, let response = response else {
            throw RequestError.invalidRequest
        }
        return (data, response)
    }
}

// MARK: - Client
enum MockError: Error, Equatable {
    case err
}

final class MockHTTPClient: HTTPClient {
    var environment: EnvironmentType
    var urlSession: URLSessionType
    
    init(_ environment: EnvironmentType, session: URLSessionType) {
        self.environment = environment
        self.urlSession = session
    }
}

final class MockCombineHTTPClient: CombineHTTPClient {
    var environment: EnvironmentType
    var urlSession: CombineURLSessionType
    
    init(_ environment: EnvironmentType, session: CombineURLSessionType) {
        self.environment = environment
        self.urlSession = session
    }
}

final class MockAsyncHTTPClient: AsyncHTTPClient {
    var environment: EnvironmentType
    var urlSession: AsyncURLSessionType
    
    init(_ environment: EnvironmentType, session: AsyncURLSessionType) {
        self.environment = environment
        self.urlSession = session
    }
}
