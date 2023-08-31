//
//  ClientTests.swift
//  
//
//  Created by Brian Munjoma.
//

import XCTest
@testable import Poppify

final class ClientTests: XCTestCase {
    
    var sut: Client!
    var environment: EnvironmentType!
    var session: MockURLSession!
    var resource: Resource<String>!
    
    override func setUp() {
        resource = Resource(request: MockCustomRequest(path: "/path")) { _ in return "Mock"}
        environment = MockSecureEnvironment()
        session = MockURLSession()
        sut = MockClient(environment, session: session)
    }
    
    override func tearDown() {
        sut = nil
        session = nil
        environment = nil
        resource = nil
    }
    
    func test_Client_NoData_NoResponse_WithError() {
        
        // Given
        session.error = MockError.err
        
        var apiError: RequestError?
        let expecation = expectation(description: "Loading URL with no data")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .failure(let error): apiError = error
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertEqual(apiError, RequestError.response(error: MockError.err))
    }
    
    func test_Client_NoData_WrongResponseType_ErrorInvalidResponse() {
        
        // Given
        session.response = MockResponse.create()
        
        var apiError: RequestError?
        let expecation = expectation(description: "Loading URL")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .failure(let error): apiError = error
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertEqual(apiError, RequestError.invalidResponse)
    }
    
    func test_Client_NoData_ResponseNot200_ErrorUnhandledStatusCode() {
        
        // Given
        session.response = MockResponse.create(withCode: 100)
        var apiError: RequestError?
        let expecation = expectation(description: "Loading URL")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .failure(let error): apiError = error
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertEqual(apiError, RequestError.unhandledStatusCode(100))
    }
    
    func test_Client_NoData_Response200_ErrorInvalidData() {
        
        // Given
        session.response = MockResponse.create(withCode: 200)
        var apiError: RequestError?
        let expecation = expectation(description: "Loading URL")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .failure(let error): apiError = error
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertEqual(apiError, RequestError.invalidData)
    }
    
    func test_Client_BadData_Response200_DecodeError() {
        
        // Given
        resource = Resource(request: MockCustomRequest(path: "/path"))  { _ in throw RequestError.decode(error: MockError.err)}
        session.response = MockResponse.create(withCode: 200)
        session.data = "Bad Data".data(using: .utf8)!
        var apiError: RequestError?
        
        let expecation = expectation(description: "Loading URL")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .failure(let error): apiError = error
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertEqual(apiError, RequestError.decode(error: MockError.err))
    }
    
    func test_Client_WithData_Response200_NoError() {
        
        // Given
        session.response = MockResponse.create(withCode: 200)
        session.data = "data".data(using: .utf8)!
        var data: String?
        
        let expecation = expectation(description: "Loading URL")
        
        // When
        sut.executeRequest(with: resource) { result in
            switch result {
            case .success(let sData): data = sData
            default: break
            }
            
            expecation.fulfill()
        }?.resume()
        
        wait(for: [expecation], timeout: 0.1)
        
        // Then
        XCTAssertNotNil(data)
    }
    
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class AsyncClientTests: XCTestCase {
    var sut: Client!
    var environment: EnvironmentType!
    var session: MockURLSession!
    var resource: Resource<String>!

    override func setUp() {
        resource = Resource(request: MockCustomRequest(path: "/path")) { _ in return "Mock"}
        environment = MockSecureEnvironment()
        session = MockURLSession()
        sut = MockClient(environment, session: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        environment = nil
        resource = nil
    }

    func test_AsyncClient_NoData_NoResponse_ErrorResponse() async {

        // Given
        session.error = MockError.err
        
        // When
        let result = await sut.executeRequest(with: resource)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, RequestError.response(error: MockError.err))
        default:
            XCTFail()
        }
    }
    
    func test_AsyncClient_Data_WrongResponseType_ErrorInvalidResponse() async {
        
        // Given
        session.response = MockResponse.create()
        session.data = Data()
        
        // When
        let result = await sut.executeRequest(with: resource)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, RequestError.invalidResponse)
        default:
            XCTFail()
        }
    }
    
    func test_AsyncClient_NoData_ResponseNot200_ErrorUnhandledStatusCode() async {
        
        // Given
        session.response = MockResponse.create(withCode: 100)
        session.data = Data()
        
        // When
        let result = await sut.executeRequest(with: resource)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, RequestError.unhandledStatusCode(100))
        default:
            XCTFail()
        }
    }
    
    func test_AsyncClient_BadData_Response200_DecodeError() async {
        
        // Given
        resource = Resource(request: MockCustomRequest(path: "/path"))
        session.response = MockResponse.create(withCode: 200)
        session.data = "Bad Data".data(using: .utf8)!
        
        // When
        let result = await sut.executeRequest(with: resource)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, RequestError.decode(error: MockError.err))
        default:
            XCTFail()
        }
    }
    
    func test_AsyncClient_WithData_Response200_NoError() async {
        
        // Given
        session.response = MockResponse.create(withCode: 200)
        session.data = "data".data(using: .utf8)!
        
        // When
        let result = await sut.executeRequest(with: resource)
        
        // Then
        switch result {
        case .failure(_):
            XCTFail()
        default:
            break
        }
    }
}
