// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftUICollection",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftUICollection",
            targets: ["SwiftUICollection"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUICollection"
        )
    ]
)
