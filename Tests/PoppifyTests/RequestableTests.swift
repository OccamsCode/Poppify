//
//  RequestableTests.swift
//  
//
//  Created by Brian Munjoma
//

import XCTest
@testable import Poppify

final class DefaultRequestableTests: XCTestCase {

    var sut: Requestable!
    let mockPath = "/v1/mock"

    override func setUpWithError() throws {
        sut = MockDefaultRequest(path: mockPath)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testDefaultValue_method_isGET() {

        let result = sut.method

        XCTAssertEqual(result, .GET)
    }

    func testDefaultValue_parameters_isEmpty() {

        let result = sut.parameters

        XCTAssertEqual(result, [])
    }

    func testDefaultValue_headers_isAcceptJSON() {

        let result = sut.headers

        XCTAssertEqual(result, [:])
    }

    func testDefaultValue_body_isNil() {

        let result = sut.body

        XCTAssertNil(result)
    }
}

final class CustomRequestableTests: XCTestCase {

    var sut: Requestable!
    let mockPath = "/v1/mock"

    override func setUpWithError() throws {
        sut = MockCustomRequest(path: mockPath)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCustomRequest_method_isPOST() {

        let result = sut.method

        XCTAssertEqual(result, .POST)
    }

    func testCustomRequest_parameters_isCorrectURLQueryItem() {

        let result = sut.parameters

        XCTAssertEqual(result, [URLQueryItem(name: "name", value: "value")])
    }

    func testCustomRequest_headers_isContentLength() {

        let result = sut.headers

        XCTAssertEqual(result, ["Content-Length": "348"])
    }

    func testCustomRequest_body_isNotNil() {

        let result = sut.body

        XCTAssertNotNil(result)
    }
}

final class RequestableURLTests: XCTestCase {
    var environment: EnvironmentType!
    var sut: Requestable!
    let mockPath = "/v1/mock"
    
    override func setUp() {
        environment = MockSecureEnvironment()
        sut = MockCustomRequest(path: mockPath)
    }
    
    override func tearDown() {
        sut = nil
        environment = nil
    }
    
    func testCreatedURL_scheme_isCorrectScheme() {
        
        let result = sut.url(using: environment)
        
        XCTAssertEqual(result?.scheme, "https")
    }
    
    func testCreatedURL_host_isCorrectHost() {
        
        let result = sut.url(using: environment)
        
        XCTAssertEqual(result?.host, "api.mock.org")
    }
    func testCreatedURL_port_isCorrectPort() {
        
        let result = sut.url(using: environment)
        
        XCTAssertEqual(result?.port, 443)
    }
    
    func testCreatedURL_path_isCorrectPath() {
        
        let result = sut.url(using: environment)
        
        XCTAssertEqual(result?.path, "/v1/mock")
    }
    
    func testCreatedURL_queryItems_containsQueryItems() throws {
        
        let result = try XCTUnwrap(sut.url(using: environment)?.query)
        
        for queryItem in sut.parameters {
            XCTAssertTrue(result.contains(queryItem.name))
            
            let value = try XCTUnwrap(queryItem.value)
            XCTAssertTrue(result.contains(value))
        }
    }
    
    func testCreatedURL_queryItems_isContainsUnsecureSecret() throws {
        
        let unsecure = MockUnsecureEnvironment()
        let result = try XCTUnwrap(sut.url(using: unsecure)?.query)
        
        guard case let .queryItem(queryItem) = unsecure.secret else {
            return XCTFail()
        }
        
        XCTAssertTrue(result.contains(queryItem.name))
        
        let value = try XCTUnwrap(queryItem.value)
        XCTAssertTrue(result.contains(value))
    }
}
