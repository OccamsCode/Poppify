//
//    URLSessionType.swift
//    Poppify
//
//    Created by Brian Munjoma on 15/11/2024.
//
//    Copyright (c) 2024 Brian Munjoma
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Combine
import Foundation

/// A protocol representing a type that can perform URL session tasks.
public protocol URLSessionType {
    /// Creates a data task with the specified request and completion handler.
    ///
    /// - Parameters:
    ///   - request: The URL request to be used in the data task.
    ///   - completion: The completion handler to be called when the data task completes.
    /// - Returns: A task representing the ongoing data task.
    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskType
}
