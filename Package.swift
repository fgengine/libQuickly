// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libQuicklyView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "libQuicklyView-Dynamic",
            type: .dynamic,
            targets: [ "libQuicklyView" ]
        ),
        .library(
            name: "libQuicklyView-Static",
            type: .static,
            targets: [ "libQuicklyView" ]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "libQuicklyView"
        )
    ]
)
