// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Harmony-S3",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Harmony-S3",
            targets: ["Harmony-S3"]
        ),
        .library(
            name: "Harmony-S3-Dynamic",
            type: .dynamic,
            targets: ["Harmony-S3"]
        ),
        .library(
            name: "Harmony-S3-Static",
            type: .static,
            targets: ["Harmony-S3"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
        .package(url: "https://github.com/JoeMatt/Harmony.git", from: "1.1.1")
    ],
    targets: [
        .target(
            name: "Harmony-S3",
            dependencies: [
                "Harmony",
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoSES", package: "soto"),
                .product(name: "SotoIAM", package: "soto")
            ]
        ),
        .testTarget(
            name: "HarmonyS3Tests",
            dependencies: [
                "Harmony-S3"
            ]
        )
    ]
)
