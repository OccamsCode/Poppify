# Poppify

[![License: MIT](https://img.shields.io/badge/License-MIT-leafgreen.svg)](https://opensource.org/licenses/MIT)
[![Package Build & Test](https://github.com/OccamsCode/Poppify/actions/workflows/build.yml/badge.svg)](https://github.com/OccamsCode/Poppify/actions/workflows/build.yml)

## Overview

Poppify is a lightweight, protocol-oriented networking framework implemented in the Swift programming language. It is designed to provide a flexible and extensible abstraction over HTTP networking, supporting multiple asynchronous paradigms while maintaining a clear separation of concerns.

The framework emphasises composability through protocols, enabling developers to define environments, requests, and clients independently.

## Installation

### Swift Package Manager

Poppify can be integrated into your project using Swift Package Manager (SPM). Apple provides an official guide on adding package dependencies, which can be found here:
https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app

To install Poppify via Xcode:

1. Open Xcode and select **File → Add Packages...**
2. Enter the repository URL:
   
   https://github.com/OccamsCode/Poppify

Alternatively, you may add Poppify directly to your `Package.swift` file:

```swift
.package(url: "https://github.com/OccamsCode/Poppify/", from: "1.1.0")
```

## Usage

A typical Poppify workflow consists of the following steps:

1. [Create an environment](#create-an-environment)
2. [Define a request](#define-a-request)
3. [Configure a client](#configure-a-client)
4. [Execute the request](#execute-the-request)

Each step is described in detail below.

### Creating an Environment

The `EnvironmentType` protocol defines the characteristics of a network environment, including:

- Base endpoint
- Network scheme (HTTP or HTTPS)
- Port configuration
- Additional HTTP headers
- API secret handling (header or query parameter)

Poppify provides a concrete implementation, `EnvironmentInfo`, which satisfies `EnvironmentType` and can be used directly. Custom environments may also be defined by conforming to the protocol.

```swift
let testEnvironment = EnvironmentInfo(
    scheme: .secure,
    endpoint: "jsonplaceholder.typicode.com",
    additionalHeaders: [:],
    port: nil,
    secret: .header("apiKey", value: "some_api_key")
)

struct CustomEnvironment: EnvironmentType {
    ...
}
```

### Creating a Request

Requests are defined by conforming to the `Requestable` protocol. This protocol encapsulates the properties required to execute a request within a given environment, such as:

- HTTP method
- Request path
- Headers
- Request body

```swift
struct GetPostsRequest: Requestable {
    let path: String = "/posts"
    let parameters: [URLQueryItem]
    
    init(userId: String) {
        self.parameters = [
            URLQueryItem(name: "userId", value: userId)
        ]
    }
}

let request = GetPostsRequest(userId: "1")
```

### Creating a Client

Clients are responsible for executing requests against a specified environment using a provided `URLSession`. Poppify supports three client variants, each aligned with a different asynchronous programming model:

- `HTTPClient` – Closure-based execution
- `CombineHTTPClient` – Combine framework support
- `AsyncHTTPClient` – Swift concurrency (`async/await`)

```swift
struct CustomAsyncClient: AsyncHTTPClient {
    var environment: EnvironmentType
    var urlSession: URLSessionType
}

let client = CustomAsyncClient(
    environment: testEnvironment,
    urlSession: URLSession.shared
)
```

### Executing a Request

#### Closure-Based Execution

For clients conforming to `HTTPClient`, requests can be executed using completion handlers:

```swift
let task = client.executeRequest(with: request) { result in
    switch result {
    case .success(let data, let response):
        print("Received data: \(data)")
    case .failure(let error):
        print(error)
    }
}

task?.resume()
```

#### Swift Concurrency (`async/await`)

Clients that support Swift concurrency may execute requests using `async/await` syntax:

```swift
let (data, response) = try await client.asyncRequest(with: request)
```

#### Combine

For Combine-based clients, requests are exposed as publishers:

```swift
cancellable = apiClient.publisherRequest(with: request)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                // Handle successful completion
            case .failure(let error):
                // Handle error
            }
        },
        receiveValue: { result in
            let (data, response) = result
            print("Received data: \(data)")
        }
    )
```
