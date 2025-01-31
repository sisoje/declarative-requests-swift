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
        .library(
            name: "DeclarativeRequestsExt",
            targets: ["DeclarativeRequestsExt"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        .target(
            name: "DeclarativeRequests"
        ),
        .target(
            name: "DeclarativeRequestsExt",
            dependencies: ["DeclarativeRequests"]
        ),
        .testTarget(
            name: "DeclarativeRequestsTests",
            dependencies: ["DeclarativeRequests"]
        ),
        .testTarget(
            name: "DeclarativeRequestsExtTests",
            dependencies: ["DeclarativeRequestsExt"]
        ),
        .testTarget(
            name: "VaporTests",
            dependencies: ["DeclarativeRequestsExt", .product(name: "Vapor", package: "vapor")]
        ),
    ]
)
