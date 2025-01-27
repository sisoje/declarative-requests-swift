// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeclarativeRequests",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DeclarativeRequests",
            targets: ["DeclarativeRequests"]
        ),
    ],
    targets: [
        .target(
            name: "DeclarativeRequests"),
        .testTarget(
            name: "DeclarativeRequestsTests",
            dependencies: ["DeclarativeRequests"]
        ),
    ]
)
