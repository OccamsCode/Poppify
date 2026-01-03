//
//  XCTestCase+Extension.swift
//  Poppify
//
//  Created by Brian Munjoma on 27/06/2025.
//

import XCTest

/// Asynchronously asserts that the given expression throws a specific error.
///
/// - Parameters:
///   - expression: An `async` throwing expression that is expected to fail.
///   - errorThrown: The specific error that is expected to be thrown.
///   - message: An optional message to display if the assertion fails. Defaults to `"This method should fail"`.
///   - file: The file name where the failure occurs. Defaults to the current file.
///   - line: The line number where the failure occurs. Defaults to the current line.
func XCTAssertThrowsErrorAsync<T, R>(
    _ expression: @autoclosure () async throws -> T,
    _ errorThrown: @autoclosure () -> R,
    _ message: @autoclosure () -> String = "This method should fail",
    file: StaticString = #filePath,
    line: UInt = #line
) async where R: Equatable, R: Error {
    do {
        let _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        XCTAssertEqual(error as? R, errorThrown())
    }
}


/// Asynchronously asserts that the given expression does **not** throw an error.
///
/// - Parameters:
///   - expression: An `async` throwing expression that is expected **not** to fail.
///   - message: An optional message to display if the assertion fails. Defaults to `"This method should not fail"`.
///   - file: The file name where the failure occurs. Defaults to the current file path.
///   - line: The line number where the failure occurs. Defaults to the current line.
func XCTAssertNoThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "This method should not fail",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        let _ = try await expression()
    } catch {
        XCTFail(message(), file: file, line: line)
    }
}
