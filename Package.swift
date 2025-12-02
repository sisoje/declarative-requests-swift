// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DeclarativeRequests",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DeclarativeRequests",
            targets: ["DeclarativeRequests"]
        ),
    ],
//    dependencies: [
//        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
//    ],
    targets: [
        .target(
            name: "DeclarativeRequests"
        ),
        .testTarget(
            name: "DeclarativeRequestsTests",
            dependencies: ["DeclarativeRequests"]
        ),
//        .testTarget(
//            name: "VaporTests",
//            dependencies: ["DeclarativeRequests", .product(name: "Vapor", package: "vapor")]
//        ),
    ]
)
