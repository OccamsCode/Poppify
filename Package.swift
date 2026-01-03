// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Poppify",
    platforms: [.iOS(.v13), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v5)],
    products: [
        .library(
            name: "Poppify",
            targets: ["Poppify"]),
    ],
    targets: [
        .target(
            name: "Poppify",
            dependencies: []),
        .testTarget(
            name: "PoppifyTests",
            dependencies: ["Poppify"]),
    ]
)
