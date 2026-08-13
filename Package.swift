// swift-tools-version: 6.3
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
    dependencies: [
    ],
    targets: [
        .target(
            name: "DeclarativeRequests"
        ),
        .testTarget(
            name: "DeclarativeRequestsTests",
            dependencies: ["DeclarativeRequests"]
        )
    ]
)
