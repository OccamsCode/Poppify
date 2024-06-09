# Poppify

[![License: MIT](https://img.shields.io/badge/License-MIT-leafgreen.svg)](https://opensource.org/licenses/MIT) [![Package Build & Test](https://github.com/OccamsCode/Poppify/actions/workflows/build.yml/badge.svg)](https://github.com/OccamsCode/Poppify/actions/workflows/build.yml)

### What is Poppify?

A simple Protocol based networking framework  written in [Swift](https://developer.apple.com/swift/) programming language.

## Installing Poppify

### Swift Package Manager

To install Poppify using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Poopify repo with the current version:

1. In Xcode, select “File” → “Add Packages...”
1. Enter https://github.com/OccamsCode/Poppify

or you can add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/OccamsCode/Poppify/", from: "1.0.6")
```

## Usage

1. [Create the Environment](#create-the-environment)
2. [Create the Request](#create-the-request)
3. [Create the Resource](#create-the-resource)
4. [Create the Client](#create-the-client)
5. [Execute the Request](#execute-the-request)

### Create the Environment

The `EnvironmentType` protocol represents various aspects of an environment such as; base endpoint, port, HTTP/HTTPS and whether the api secret sent in the header or as a query item.

The existing `EnvironmentInfo` type, which simply conforms to `EnvironmentType`, can be used or a custom environment can be created

```swift
let testEnvironment = EnvironmentInfo(scheme: .secure,
                                    endpoint: "jsonplaceholder.typicode.com",
                                    additionalHeaders: [:],
                                    port: nil,
                                    secret: .header("apiKey", value: "some_api_key"))

struct CustomEnvironment: EnvironmentType {
    ...
}
```

### Create the Request

The `Requestable` protocol represents aspects of a request to be execute in an environment such as; method, path, headers & body

```swift
struct CustomRequest: Requestable {
    var path: String
}

let request = CustomRequest(path: "/posts")
```

### Create the Resource

A `Resource` encapsulates a request it's decoding strategy.

When the decoding type is `Decodable`, the decoding strategy attempts to use the provided `JSONParser`

```swift
let resource = Resource<String>(request: request)
```

### Create the Client

A `Client` executes a `Resource` with a given `Environment` and `URLSession`

```swift
struct CustomClient: Client {
    var environment: EnvironmentType
    var urlSession: URLSessionType
}

let task = CustomClient(environment: testEnvironment, urlSession: URLSession.shared)
```

### Execute the Request

`Client` supports requests using closures 

```swift
let task = client.executeRequest(with: resource) { result in
    switch result {
    case .success(let string):
        print(string)
    case .failure(let error):
        print(error)
    }
}

task?.resume()
```

`Client` supports requests using `async/await`

```swift
let result = await client.executeRequest(with: resource)

switch result {
case .success(let string):
    print(string)
case .failure(let error):
    print(error)
}
```

`Client` supports requests using `Combine`

```swift
cancellable = apiClient.executeRequestPublisher(with: userResource)
    .sink(receiveCompletion: { completion in
        switch completion {
            case .finished:
            // Handle completion
            case .failure(let error):
            // Handle error
            }
    }, receiveValue: { user in
        // Handle successful result
        print("Received user: \(user)")
    }
)
```
