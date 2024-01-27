// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ButtonKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macOS(.v12), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ButtonKit",
            targets: ["ButtonKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ButtonKit",
            swiftSettings: [
                .strictConcurrency,
                .warnLongExpressionTypeChecking
            ]),
        .testTarget(
            name: "ButtonKitTests",
            dependencies: ["ButtonKit"]),
    ]
)

extension SwiftSetting {
    static let strictConcurrency = enableUpcomingFeature("StrictConcurrency")
    static let warnLongExpressionTypeChecking = unsafeFlags(
        [
            "-Xfrontend", "-warn-long-expression-type-checking=100",
            "-Xfrontend", "-warn-long-function-bodies=100",
        ],
        .when(configuration: .debug)
    )
}
