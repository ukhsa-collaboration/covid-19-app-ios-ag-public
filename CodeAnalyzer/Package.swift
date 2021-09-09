// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeAnalyzer",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CodeAnalyzer",
            targets: ["CodeAnalyzer"]
        ),
    ],
    dependencies: [
        .package(
            name: "SwiftSyntax",
            url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CodeAnalyzer",
            dependencies: ["SwiftSyntax"]
        ),
        .testTarget(
            name: "CodeAnalyzerTests",
            dependencies: ["CodeAnalyzer"]
        ),
    ]
)
