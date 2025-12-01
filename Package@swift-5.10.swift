// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ButtonKit",
    platforms: [.iOS(.v16), .tvOS(.v16), .watchOS(.v10), .macOS(.v13), .visionOS(.v1)],
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
