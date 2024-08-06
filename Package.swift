// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ButtonKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macOS(.v12), .visionOS(.v1)],
    products: [
        .library(name: "ButtonKit", targets: ["ButtonKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "1.2.0")
    ],
    targets: [
        .target(name: "ButtonKit", dependencies: [
            .product(name: "IssueReporting", package: "swift-issue-reporting")
        ]),
    ],
    swiftLanguageVersions: [.v6]
)
