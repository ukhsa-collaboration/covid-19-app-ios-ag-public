// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS("13.5"),
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
        .library(
            name: "Interface",
            targets: ["Interface"]
        ),
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Integration",
            targets: ["Integration"]
        ),
        .library(
            name: "Scenarios",
            targets: ["Scenarios"]
        ),
        .library(
            name: "TestSupport",
            targets: ["TestSupport"]
        ),
    ],
    dependencies: [
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.8.0"),
        .package(name: "AppConfiguration", url: "https://github.com/nhsx/covid-19-app-configuration-public.git", .branch("master")),
        .package(name: "ZIPFoundation", url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11"),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(name: "RiskScore", url: "https://github.com/nhsx/riskscore-swift-public", .upToNextMajor(from: "3.2.0")),
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "Localization",
            dependencies: [
                "Common",
            ]
        ),
        .target(
            name: "Interface",
            dependencies: [
                "Common",
                "Localization",
            ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "Common",
                "ZIPFoundation",
                "RiskScore",
            ],
            resources: [
                .copy("Resources/LocalAuthorities.json"),
            ]
        ),
        .target(
            name: "Integration",
            dependencies: [
                "Common",
                "Localization",
                "Domain",
                "Interface",
                .product(name: "ProductionConfiguration", package: "AppConfiguration"),
            ]
        ),
        .target(
            name: "Scenarios",
            dependencies: [
                "Common",
                "Interface",
                "Integration",
                "SwiftProtobuf",
                .product(name: "ScenariosConfiguration", package: "AppConfiguration"),
            ]
        ),
        .target(
            name: "TestSupport",
            dependencies: [
                "Common",
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: [
                "TestSupport",
                "Common",
                "Scenarios",
            ]
        ),
        .testTarget(
            name: "TestSupportTests",
            dependencies: [
                "TestSupport",
                "Common",
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                "Scenarios",
                "TestSupport",
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "Integration",
                "TestSupport",
                "Domain",
                "Scenarios",
            ]
        ),
        .testTarget(
            name: "InterfaceTests",
            dependencies: ["Interface"]
        ),
        .testTarget(
            name: "ScenariosTests",
            dependencies: [
                "Scenarios",
                "TestSupport",
            ]
        ),
    ]
)
