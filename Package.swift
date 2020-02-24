// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CurlGen",
    products: [
        .library(
            name: "CurlGen",
            targets: ["CurlGen"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CurlGen",
            dependencies: []
        ),
        .testTarget(
            name: "CurlGenTests",
            dependencies: ["CurlGen"]
        ),
    ]
)
