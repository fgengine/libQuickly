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
            name: "libQuicklyXml",
            type: .static,
            targets: [ "libQuicklyXml" ]
        ),
        .library(
            name: "libQuicklyKeychain",
            type: .static,
            targets: [ "libQuicklyKeychain" ]
        ),
        .library(
            name: "libQuicklyQRCode",
            type: .static,
            targets: [ "libQuicklyQRCode" ]
        ),
        .library(
            name: "libQuicklyApi",
            type: .static,
            targets: [ "libQuicklyApi" ]
        ),
        .library(
            name: "libQuicklyDatabase",
            type: .static,
            targets: [ "libQuicklyDatabase" ]
        ),
        .library(
            name: "libQuicklyDataSource",
            type: .static,
            targets: [ "libQuicklyDataSource" ]
        ),
        .library(
            name: "libQuicklyPermission",
            type: .static,
            targets: [ "libQuicklyPermission" ]
        ),
        .library(
            name: "libQuicklyView",
            type: .static,
            targets: [ "libQuicklyView" ]
        ),
        .library(
            name: "libQuicklyRemoteImageView",
            type: .static,
            targets: [ "libQuicklyRemoteImageView" ]
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
            name: "libQuicklyXml",
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
            name: "libQuicklyQRCode",
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
            name: "libQuicklyDatabase",
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
            name: "libQuicklyPermission",
            dependencies: [
                .target(name: "libQuicklyObserver")
            ]
        ),
        .target(
            name: "libQuicklyView",
            dependencies: [
                .target(name: "libQuicklyObserver")
            ]
        ),
        .target(
            name: "libQuicklyRemoteImageView",
            dependencies: [
                .target(name: "libQuicklyApi"),
                .target(name: "libQuicklyView")
            ]
        )
    ]
)
