//
//    HTTPClient.swift
//    Poppify
//
//    Created by Brian Munjoma on 18/11/2024.
//
//    Copyright (c) 2023 Brian Munjoma
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

import Foundation

public protocol HTTPClient: HTTPClientType {
    /// Executes a network request with the specified resource and returns the result asynchronously via a completion handler.
    ///
    /// - Parameters:
    ///   - request: The resource representing the network request to be executed.
    ///   - completion: A closure to be executed when the request finishes, containing a `Result` with the `HTTPClientResponse` or an `Error`.
    /// - Returns: An optional `URLSessionTaskType` representing the ongoing network task. Can be used to monitor or cancel the task.
    func executeRequest(
        with request: Requestable,
        completion: @escaping (Result<HTTPClientResponse, Error>) -> Void
    ) -> URLSessionTaskType?
}

public extension HTTPClient {
    func executeRequest(
        with request: Requestable,
        completion: @escaping (Result<HTTPClientResponse, Error>) -> Void
    ) -> URLSessionTaskType? {
        
        guard let urlRequest = URLRequest(request: request, in: environment) else {
            completion(.failure(RequestError.invalidRequest))
            return nil
        }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error {
                return completion(.failure(RequestError.response(error: error)))
            }
            
            guard let data else {
                return completion(.failure(RequestError.invalidData))
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return completion(.failure(RequestError.invalidRequest))
            }
            
            completion(.success((data, httpURLResponse)))
        }
        return task
    }
    
}
