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
        .library(name: "libQuicklyCore",type: .static, targets: [ "libQuicklyCore" ]),
        .library(name: "libQuicklyShell", type: .static, targets: [ "libQuicklyShell" ]),
        .library(name: "libQuicklyObserver", type: .static, targets: [ "libQuicklyObserver" ]),
        .library(name: "libQuicklyJson", type: .static, targets: [ "libQuicklyJson" ]),
        .library(name: "libQuicklyXml", type: .static, targets: [ "libQuicklyXml" ]),
        .library(name: "libQuicklyKeychain", type: .static, targets: [ "libQuicklyKeychain" ]),
        .library(name: "libQuicklyQRCode", type: .static, targets: [ "libQuicklyQRCode" ]),
        .library(name: "libQuicklyApi", type: .static, targets: [ "libQuicklyApi" ]),
        .library(name: "libQuicklyDatabase", type: .static, targets: [ "libQuicklyDatabase" ]),
        .library(name: "libQuicklyDataSource", type: .static, targets: [ "libQuicklyDataSource" ]),
        .library(name: "libQuicklyPermission", type: .static, targets: [ "libQuicklyPermission" ]),
        .library(name: "libQuicklyView", type: .static, targets: [ "libQuicklyView" ]),
        .library(name: "libQuicklyRemoteImageView", type: .static, targets: [ "libQuicklyRemoteImageView" ]),
        .library(name: "libQuicklyLog", type: .static, targets: [ "libQuicklyLog" ]),
        .library(name: "libQuicklyLogUI", type: .static, targets: [ "libQuicklyLogUI" ]),
        .library(name: "libQuicklyInAppPurchase", type: .static, targets: [ "libQuicklyInAppPurchase" ])
    ],
    dependencies: [
        .package(name: "TPInAppReceipt", url: "https://github.com/tikhop/TPInAppReceipt.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "libQuicklyCore"),
        .target(name: "libQuicklyShell", dependencies: [ .target(name: "libQuicklyCore", condition: .when(platforms: [ .macOS ])) ]),
        .target(name: "libQuicklyObserver", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyJson", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyXml", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyKeychain", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyQRCode", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyApi", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyDatabase", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyDataSource", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyPermission", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver") ]),
        .target(name: "libQuicklyView", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver") ]),
        .target(name: "libQuicklyRemoteImageView", dependencies: [ .target(name: "libQuicklyApi"), .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyLog", dependencies: [ .target(name: "libQuicklyCore") ]),
        .target(name: "libQuicklyLogUI", dependencies: [ .target(name: "libQuicklyLog"), .target(name: "libQuicklyObserver"), .target(name: "libQuicklyView") ]),
        .target(name: "libQuicklyInAppPurchase", dependencies: [ .target(name: "libQuicklyCore"), .target(name: "libQuicklyObserver"), .product(name: "TPInAppReceipt", package: "TPInAppReceipt") ])
    ]
)
