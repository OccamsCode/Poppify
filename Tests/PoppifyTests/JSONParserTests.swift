//
//  JSONParserTests.swift
//  
//
//  Created by Brian Munjoma
//

import XCTest
@testable import Poppify

final class JSONParserTests: XCTestCase {

    var sut: JSONParser!
    
    override func setUpWithError() throws {
        sut = JSONParser()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_closureParser_InvalidData_ResultsInError() {
        
        var result: ParserError?
        
        let expecation = expectation(description: "JSON Parsing")
        let errData = "invalid".data(using: .utf8)!
        
        sut.parse(errData, into: MockModel.self) { _result in
            switch _result {
            case .failure(let error): result = error
            default: XCTFail()
            }
            expecation.fulfill()
        }
        
        wait(for: [expecation], timeout: 0.1)
        
        XCTAssertEqual(result, ParserError.jsonDecodeError)
        
    }
    
    func test_closureParser_ValidData_NoError() {
        
        var result: MockModel?
        
        let expecation = expectation(description: "JSON Parsing")
        let errData = """
            {
                "name":"Gordon",
                "age":10,
                "isDone": true
            }
            """.data(using: .utf8)!
        
        sut.parse(errData, into: MockModel.self) { _result in
            switch _result {
            case .success(let model): result = model
            default: XCTFail()
            }
            expecation.fulfill()
        }
        
        wait(for: [expecation], timeout: 0.1)
        
        XCTAssertNotNil(result)
        
    }

    func test_returnParser_InvalidData_ResultsInError() {
        
        let errData = "invalid".data(using: .utf8)!
        
        XCTAssertThrowsError(try sut.parse(errData, into: MockModel.self)) { error in
            XCTAssertTrue(error is DecodingError)
        }

    }
    
    func test_returnParser_ValidData_NoError() {
        
        let errData = """
            {
                "name":"Gordon",
                "age":10,
                "isDone": true
            }
            """.data(using: .utf8)!
        
        XCTAssertNoThrow(try sut.parse(errData, into: MockModel.self))
        
    }

}
