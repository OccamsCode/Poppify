//
//  URLRequestTest.swift
//  
//
//  Created by Brian Munjoma.
//

import XCTest
@testable import Poppify

final class SecureEnvironmentURLRequestTest: XCTestCase {
    var environment: EnvironmentType!
    var requestable: Requestable!
    
    override func setUp() {
        environment = MockSecureEnvironment()
        requestable = MockCustomRequest(path: "/path")
    }
    
    override func tearDown() {
        requestable = nil
        environment = nil
    }
    
    func testCreateURLRequest_httpMethod_isCorrectMethod() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment))
        
        XCTAssertEqual(result.httpMethod, "POST")
    }
    
    func testCreateURLRequest_httpBody_isNotNil() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment))
        
        XCTAssertNotNil(result.httpBody)
    }
    
    func testCreateURLRequest_httpHeaders_containRequestHeaders() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment)?.allHTTPHeaderFields)
        
        XCTAssertTrue(result.contains { (rKey, rValue) in
            rKey == "Content-Length" && rValue == "348"
        })
    }
    
    func testCreateURLRequest_httpHeaders_containAdditionalHeaders() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment)?.allHTTPHeaderFields)
        
        XCTAssertTrue(result.contains { (rKey, rValue) in
            rKey == "Connection" && rValue == "Close"
        })
    }
    
    func testCreateURLRequest_httpHeaders_containSecretHeaders() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment)?.allHTTPHeaderFields)

        XCTAssertTrue(result.contains { (rKey, rValue) in
            rKey == "X-API-KEY" && rValue == "c6fb701caa6b1fbe4290a16e77b564b8"
        })
    }
    
    func testCreateURLRequest_httpHeaders_doesNotContainSecretQueryItems() throws {
        let result = try XCTUnwrap(URLRequest(request: requestable, in: environment)?.allHTTPHeaderFields)

        XCTAssertFalse(result.contains { (rKey, rValue) in
            rKey == "API-KEY" && rValue == "Poppify-MD5"
        })
    }

    func testCreateURLRequest_httpMethod_isHEAD() throws {
        let headRequest = MockHeadRequest(path: "/path")
        let result = try XCTUnwrap(URLRequest(request: headRequest, in: environment))

        XCTAssertEqual(result.httpMethod, "HEAD")
    }

    func testCreateURLRequest_headerPrecedence_environmentOverRequest_environmentWins() throws {
        let result = try XCTUnwrap(
            URLRequest(request: MockConflictRequest(), in: MockConflictEnvironment(), headerPrecedence: .environmentOverRequest)
        )
        XCTAssertEqual(result.value(forHTTPHeaderField: "X-Source"), "environment")
    }

    func testCreateURLRequest_headerPrecedence_requestOverEnvironment_requestWins() throws {
        let result = try XCTUnwrap(
            URLRequest(request: MockConflictRequest(), in: MockConflictEnvironment(), headerPrecedence: .requestOverEnvironment)
        )
        XCTAssertEqual(result.value(forHTTPHeaderField: "X-Source"), "request")
    }

    func testCreateURLRequest_secretHeader_alwaysWinsRegardlessOfPrecedence() throws {
        let result = try XCTUnwrap(
            URLRequest(request: MockSecretConflictRequest(), in: MockSecretEnvironment(), headerPrecedence: .requestOverEnvironment)
        )
        XCTAssertEqual(result.value(forHTTPHeaderField: "X-API-KEY"), "from-secret")
    }
}

private struct MockHeadRequest: Requestable {
    let path: String
    var method: HTTP.Method { .HEAD }
}

private struct MockConflictRequest: Requestable {
    let path: String = "/path"
    var headers: [String: String] { ["X-Source": "request"] }
}

private struct MockConflictEnvironment: EnvironmentType {
    var scheme: HTTP.Scheme = .secure
    var endpoint: String = "api.mock.org"
    var additionalHeaders: [String: String] = ["X-Source": "environment"]
    var port: Int? = nil
    var basePath: String? = nil
    var secret: Secret? = nil
}

private struct MockSecretConflictRequest: Requestable {
    let path: String = "/path"
    var headers: [String: String] { ["X-API-KEY": "from-request"] }
}

private struct MockSecretEnvironment: EnvironmentType {
    var scheme: HTTP.Scheme = .secure
    var endpoint: String = "api.mock.org"
    var additionalHeaders: [String: String] = [:]
    var port: Int? = nil
    var basePath: String? = nil
    var secret: Secret? = .header("X-API-KEY", value: "from-secret")
}
