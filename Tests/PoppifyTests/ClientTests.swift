//
//  ClientTests.swift
//  Poppify
//
//  Created by Brian Munjoma.
//

import XCTest
@testable import Poppify

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class AsyncClientTests: XCTestCase {
    var request: Requestable!
    var sut: AsyncHTTPClient!
    var environment: EnvironmentType!
    var session: MockURLSession!

    override func setUp() {
        request = MockCustomRequest(path: "/path")
        environment = MockSecureEnvironment()
        session = MockURLSession()
        sut = MockAsyncHTTPClient(environment, session: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        environment = nil
    }

    func test_AsyncClient_NoData_NoResponse_ErrorResponse() async {

        // Given
        session.error = MockError.err
        
        await XCTAssertThrowsErrorAsync(
            try await sut.asyncRequest(with: request),
            MockError.err
        )
    }
    
    func test_AsyncClient_Data_WrongResponseType_ErrorInvalidResponse() async {
        
        // Given
        session.response = MockResponse.create()
        session.data = Data()

        await XCTAssertThrowsErrorAsync(
            try await sut.asyncRequest(with: request),
            RequestError.invalidResponse
        )
    }
    
    func test_AsyncClient_WithData_Response200_NoError() async {
        
        // Given
        session.response = MockResponse.create(withCode: 200)
        session.data = "data".data(using: .utf8)!
        
        await XCTAssertNoThrowsErrorAsync(
            try await sut.asyncRequest(with: request)
        )
    }
}
