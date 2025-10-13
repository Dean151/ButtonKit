// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ButtonKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macOS(.v12), .visionOS(.v1)],
    products: [
        .library(name: "ButtonKit", targets: ["ButtonKit"]),
    ],
    targets: [
        .target(name: "ButtonKit", swiftSettings: [.strictConcurrency]),
    ]
)

extension SwiftSetting {
    static let strictConcurrency = enableExperimentalFeature("StrictConcurrency")
}
