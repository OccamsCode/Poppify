//
//  ClientTests.swift
//  Poppify
//
//  Created by Brian Munjoma.
//

import Combine
import XCTest
@testable import Poppify

private struct MockInvalidRequestable: Requestable {
    let path: String = "/path"
    func url(using environment: EnvironmentType) -> URL? { return nil }
}

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

// MARK: - HTTPClientTests

final class HTTPClientTests: XCTestCase {

    var request: Requestable!
    var sut: HTTPClient!
    var session: MockURLSession!

    override func setUp() {
        request = MockCustomRequest(path: "/path")
        session = MockURLSession()
        sut = MockHTTPClient(MockSecureEnvironment(), session: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        request = nil
    }

    func test_HTTPClient_InvalidURL_ReturnsInvalidRequestError() {
        let invalidRequest = MockInvalidRequestable()

        let exp = expectation(description: "HTTPClient invalid URL")
        var receivedError: RequestError?

        let task = sut.executeRequest(with: invalidRequest) { result in
            if case .failure(let error) = result { receivedError = error as? RequestError }
            exp.fulfill()
        }
        task?.resume()
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(receivedError, .invalidRequest)
    }

    func test_HTTPClient_NilData_ReturnsInvalidDataError() {
        session.data = nil
        session.response = MockResponse.create(withCode: 200)

        let exp = expectation(description: "HTTPClient nil data")
        var receivedError: RequestError?

        let task = sut.executeRequest(with: request) { result in
            if case .failure(let error) = result { receivedError = error as? RequestError }
            exp.fulfill()
        }
        task?.resume()
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(receivedError, .invalidData)
    }

    func test_HTTPClient_WithError_ReturnsResponseError() {
        session.error = MockError.err

        let exp = expectation(description: "HTTPClient response error")
        var receivedError: RequestError?

        let task = sut.executeRequest(with: request) { result in
            if case .failure(let error) = result { receivedError = error as? RequestError }
            exp.fulfill()
        }
        task?.resume()
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(receivedError, .response(error: MockError.err))
    }

    func test_HTTPClient_WithData_Response200_ReturnsSuccess() {
        session.data = "data".data(using: .utf8)!
        session.response = MockResponse.create(withCode: 200)

        let exp = expectation(description: "HTTPClient success")
        var receivedValue: HTTPClientResponse?

        let task = sut.executeRequest(with: request) { result in
            if case .success(let value) = result { receivedValue = value }
            exp.fulfill()
        }
        task?.resume()
        wait(for: [exp], timeout: 0.1)

        XCTAssertNotNil(receivedValue)
    }
}

// MARK: - CombineHTTPClientTests

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class CombineHTTPClientTests: XCTestCase {

    var request: Requestable!
    var sut: CombineHTTPClient!
    var session: MockURLSession!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        request = MockCustomRequest(path: "/path")
        session = MockURLSession()
        sut = MockCombineHTTPClient(MockSecureEnvironment(), session: session)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        session = nil
        request = nil
    }

    func test_CombineClient_InvalidURL_ReturnsInvalidRequestError() {
        let invalidRequest = MockInvalidRequestable()

        let exp = expectation(description: "CombineClient invalid URL")
        var receivedError: RequestError?

        sut.publisherRequest(with: invalidRequest)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion { receivedError = error as? RequestError }
                exp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(receivedError, .invalidRequest)
    }

    func test_CombineClient_URLError_ReturnsResponseError() {
        session.error = URLError(.cancelled)

        let exp = expectation(description: "CombineClient URL error")
        var receivedError: RequestError?

        sut.publisherRequest(with: request)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion { receivedError = error as? RequestError }
                exp.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(receivedError, .response(error: URLError(.cancelled)))
    }

    func test_CombineClient_ValidResponse_ReturnsSuccess() {
        session.data = "data".data(using: .utf8)!
        session.response = MockResponse.create(withCode: 200)

        let exp = expectation(description: "CombineClient success")
        var receivedValue: HTTPClientResponse?

        sut.publisherRequest(with: request)
            .sink(receiveCompletion: { completion in
                if case .failure = completion { XCTFail("Expected success") }
                exp.fulfill()
            }, receiveValue: { value in
                receivedValue = value
            })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 0.1)
        XCTAssertNotNil(receivedValue)
    }
}
