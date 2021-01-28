// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libQuickly",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "libQuicklyCore",
            type: .static,
            targets: [ "libQuicklyCore" ]
        ),
        .library(
            name: "libQuicklyObserver",
            type: .static,
            targets: [ "libQuicklyObserver" ]
        ),
        .library(
            name: "libQuicklyJson",
            type: .static,
            targets: [ "libQuicklyJson" ]
        ),
        .library(
            name: "libQuicklyKeychain",
            type: .static,
            targets: [ "libQuicklyKeychain" ]
        ),
        .library(
            name: "libQuicklyApi",
            type: .static,
            targets: [ "libQuicklyApi" ]
        ),
        .library(
            name: "libQuicklyDataSource",
            type: .static,
            targets: [ "libQuicklyDataSource" ]
        ),
        .library(
            name: "libQuicklyView",
            type: .static,
            targets: [ "libQuicklyView" ]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "libQuicklyCore"
        ),
        .target(
            name: "libQuicklyObserver",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        ),
        .target(
            name: "libQuicklyJson",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        ),
        .target(
            name: "libQuicklyKeychain",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        ),
        .target(
            name: "libQuicklyApi",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        ),
        .target(
            name: "libQuicklyDataSource",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        ),
        .target(
            name: "libQuicklyView",
            dependencies: [
                .target(name: "libQuicklyCore")
            ]
        )
    ]
)
