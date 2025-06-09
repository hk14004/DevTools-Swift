// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevTools",
    platforms: [
        .iOS(.v14)
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
            name: "DevToolsRealm",
            targets: ["DevToolsRealm"]),
        .library(
            name: "DevToolsCoreData",
            targets: ["DevToolsCoreData"]),
        .library(
            name: "DevToolsLocalization",
            targets: ["DevToolsLocalization"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/realm/realm-cocoa", .upToNextMajor(from: "10.0.0"))
        
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
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsUI",
            dependencies: ["DevToolsCore"]),
        .target(
            name: "DevToolsRealm",
            dependencies: [.product(name: "RealmSwift", package: "realm-cocoa"), "DevToolsCore"]),
        .target(
            name: "DevToolsCoreData",
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
    ]
)
