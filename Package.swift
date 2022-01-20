// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libQuickly",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "libQuickly",type: .static, targets: [
            "libQuicklyApi",
            "libQuicklyCore",
            "libQuicklyDatabase",
            "libQuicklyDataSource",
            "libQuicklyInAppPurchase",
            "libQuicklyJson",
            "libQuicklyKeychain",
            "libQuicklyLog",
            "libQuicklyLogUI",
            "libQuicklyModule",
            "libQuicklyObserver",
            "libQuicklyPermission",
            "libQuicklyQRCode",
            "libQuicklyRemoteImageView",
            "libQuicklyShell",
            "libQuicklyView",
            "libQuicklyXml"
        ]),
        .library(name: "libQuicklyApi", type: .static, targets: [ "libQuicklyApi" ]),
        .library(name: "libQuicklyCore",type: .static, targets: [ "libQuicklyCore" ]),
        .library(name: "libQuicklyDatabase", type: .static, targets: [ "libQuicklyDatabase" ]),
        .library(name: "libQuicklyDataSource", type: .static, targets: [ "libQuicklyDataSource" ]),
        .library(name: "libQuicklyInAppPurchase", type: .static, targets: [ "libQuicklyInAppPurchase" ]),
        .library(name: "libQuicklyJson", type: .static, targets: [ "libQuicklyJson" ]),
        .library(name: "libQuicklyKeychain", type: .static, targets: [ "libQuicklyKeychain" ]),
        .library(name: "libQuicklyLog", type: .static, targets: [ "libQuicklyLog" ]),
        .library(name: "libQuicklyLogUI", type: .static, targets: [ "libQuicklyLogUI" ]),
        .library(name: "libQuicklyModule", type: .static, targets: [ "libQuicklyModule" ]),
        .library(name: "libQuicklyObserver", type: .static, targets: [ "libQuicklyObserver" ]),
        .library(name: "libQuicklyPermission", type: .static, targets: [ "libQuicklyPermission" ]),
        .library(name: "libQuicklyQRCode", type: .static, targets: [ "libQuicklyQRCode" ]),
        .library(name: "libQuicklyRemoteImageView", type: .static, targets: [ "libQuicklyRemoteImageView" ]),
        .library(name: "libQuicklyShell", type: .static, targets: [ "libQuicklyShell" ]),
        .library(name: "libQuicklyView", type: .static, targets: [ "libQuicklyView" ]),
        .library(name: "libQuicklyXml", type: .static, targets: [ "libQuicklyXml" ])
    ],
    dependencies: [
        .package(name: "TPInAppReceipt", url: "https://github.com/tikhop/TPInAppReceipt.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "libQuicklyApi", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyCore"),
        .target(name: "libQuicklyDatabase", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyDataSource", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyInAppPurchase", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver"), .product(name: "TPInAppReceipt", package: "TPInAppReceipt") ]),
        .target(name: "libQuicklyJson", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyKeychain", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyLog", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyLogUI", dependencies: [ .target(name: "libQuicklyLog"), .target(name: "libQuicklyObserver"), .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyModule", dependencies: [ .target(name: "libQuicklyPermission"), .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyObserver", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyPermission", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver") ]),
        .target(name: "libQuicklyQRCode", dependencies: [ .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyRemoteImageView", dependencies: [ .target(name: "libQuicklyApi"), .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyShell", dependencies: [ .target(name: "libQuicklyCore", condition: .when(platforms: [ .macOS ])) ]),
        .target(name: "libQuicklyView", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver") ]),
        .target(name: "libQuicklyXml", dependencies: [ .target(name: "libQuicklyCore") ])
    ]
)
