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
}
