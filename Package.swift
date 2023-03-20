// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HarmonyS3",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v12),
		.tvOS(.v13),
		.macCatalyst(.v13),
		.macOS(.v12)
	],
    products: [
        .library(
            name: "HarmonyS3",
            targets: ["HarmonyS3"]
        ),
        .library(
            name: "HarmonyS3-Dynamic",
            type: .dynamic,
            targets: ["HarmonyS3"]
        ),
        .library(
            name: "HarmonyS3-Static",
            type: .static,
            targets: ["HarmonyS3"]
        ),
    ],
    dependencies: [
		.package(url: "https://github.com/JoeMatt/Roxas.git", from: "1.2.0"),
		.package(url: "https://github.com/soto-project/soto-s3-file-transfer", from: "1.2.0"),
//        .package(url: "https://github.com/soto-project/soto.git", from: "6.5.0"),
        .package(url: "https://github.com/JoeMatt/Harmony.git", from: "1.2.4")
//		.package(path: "../Harmony")
    ],
    targets: [
        .target(
            name: "HarmonyS3",
            dependencies: [
                "Harmony",
				.product(name: "SotoS3FileTransfer", package: "soto-s3-file-transfer"),
//                .product(name: "SotoS3", package: "soto"),
//                .product(name: "SotoSES", package: "soto"),
//                .product(name: "SotoIAM", package: "soto")
            ]
        ),
		.executableTarget(
			name: "HarmonyS3Example",
			dependencies: [
				"HarmonyS3",
				.product(name: "HarmonyExample", package: "Harmony"),
				.product(name: "RoxasUI", package: "Roxas", condition: .when(platforms: [.iOS, .tvOS, .macCatalyst])),
			],
			linkerSettings: [
				.linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS, .macCatalyst])),
				.linkedFramework("AppKit", .when(platforms: [.macOS])),
				.linkedFramework("Cocoa", .when(platforms: [.macOS])),
				.linkedFramework("CoreData"),
			]
		),
        .testTarget(
            name: "HarmonyS3Tests",
            dependencies: [
                "HarmonyS3"
            ]
        )
    ],
	swiftLanguageVersions: [.v5]
)
