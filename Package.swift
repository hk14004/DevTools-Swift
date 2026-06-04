// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevTools",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DevToolsCore",
            targets: ["DevToolsCore"]),
        .library(
            name: "DevToolsNavigation",
            targets: ["DevToolsNavigation"]),
        .library(
            name: "DevToolsNetworking",
            targets: ["DevToolsNetworking"]),
        .library(
            name: "DevToolsUI",
            targets: ["DevToolsUI"]),
        .library(
            name: "DevToolsPersistance",
            targets: ["DevToolsPersistance"]),
        .library(
            name: "DevToolsLocalization",
            targets: ["DevToolsLocalization"]),
        .library(
            name: "DevToolsXCTest",
            targets: ["DevToolsXCTest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ashleymills/Reachability.swift", .upToNextMajor(from: "5.2.4"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DevToolsCore",
            dependencies: []),
        .target(
            name: "DevToolsNavigation",
            dependencies: []),
        .target(
            name: "DevToolsNetworking",
            dependencies: [
                "DevToolsCore",
                .product(name: "Reachability", package: "Reachability.swift")
            ]),
        .target(
            name: "DevToolsUI",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsPersistance",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsLocalization",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsXCTest",
            dependencies: ["DevToolsCore"],
            linkerSettings: [
                .linkedFramework("XCTest", .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "DevToolsNetworkingTests",
            dependencies: ["DevToolsNetworking"]),
        .testTarget(
            name: "DevToolsCoreTests",
            dependencies: ["DevToolsCore"]),
        .testTarget(
            name: "DevToolsPersistanceTests",
            dependencies: ["DevToolsPersistance", "DevToolsCore"]),
        .testTarget(
            name: "DevToolsNavigationTests",
            dependencies: ["DevToolsNavigation"])
    ]
)
