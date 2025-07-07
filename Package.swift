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
    ],
    dependencies: [],
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
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsUI",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsPersistance",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsLocalization",
            dependencies: ["DevToolsCore"]),
        .testTarget(
            name: "DevToolsNetworkingTests",
            dependencies: ["DevToolsNetworking"]),
        .testTarget(
            name: "DevToolsCoreTests",
            dependencies: ["DevToolsCore"]),
        .testTarget(
            name: "DevToolsPersistanceTests",
            dependencies: ["DevToolsPersistance", "DevToolsCore"])
    ]
)
