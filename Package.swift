// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevTools",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DevTools",
            targets: ["DevTools"]),
//        .product(name: "RealmSwift", package: "realm-swift")
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Moya/Moya", .upToNextMajor(from: "15.0.0")),
//        .package(url: "https://github.com/realm/realm-swift", .upToNextMajor(from: "10.0.0"))
        .package(name: "Realm", url: "https://github.com/realm/realm-cocoa", .upToNextMajor(from: "10.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DevTools",
            dependencies: ["Moya",.product(name: "RealmSwift", package: "Realm")]),
        .testTarget(
            name: "DevToolsTests",
            dependencies: ["DevTools"]),
    ]
)
