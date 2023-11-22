//
//  RequestErrorTests.swift
//  
//
//  Created by Brian Munjoma on 22/11/2023.
//

import XCTest
@testable import Poppify

final class RequestErrorTests: XCTestCase {
    
    func test_InvalidData_localizedDescription_isCorrect() {
        let sut: Error = RequestError.invalidData
        
        XCTAssertEqual(sut.localizedDescription, "Invalid Data")
    }

    func test_InvalidResponse_localizedDescription_isCorrect() {
        let sut: Error = RequestError.invalidResponse
        
        XCTAssertEqual(sut.localizedDescription, "Invalid Response")
    }
    
    func test_UnhandledStatusCode_localizedDescription_isCorrect() {
        let code = 500
        let sut: Error = RequestError.unhandledStatusCode(code)
        
        XCTAssertEqual(sut.localizedDescription, "Invalid Response StatusCode \(code)")
    }
    
    func test_ResponseError_localizedDescription_isCorrect() {
        let error = NSError(domain: "domain", code: -1, userInfo: [NSLocalizedDescriptionKey:"Errored"])
        let sut: Error = RequestError.response(error: error)
        
        XCTAssertEqual(sut.localizedDescription, "Response Error \(error.localizedDescription)")
    }

    func test_DecodeError_localizedDescription_isCorrect() {
        let error = NSError(domain: "domain", code: -1, userInfo: [NSLocalizedDescriptionKey:"Errored"])
        let sut: Error = RequestError.decode(error: error)
        
        XCTAssertEqual(sut.localizedDescription, "Decode Error \(error.localizedDescription)" )
    }
    
    func test_InvalidRequest_localizedDescription_isCorrect() {
        let sut: Error = RequestError.invalidRequest
        
        XCTAssertEqual(sut.localizedDescription, "Unable to create valid request for resource in environment")
    }
}
