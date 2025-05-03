// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let gitTag: String = "\"" + (Context.gitInformation?.currentTag ?? "unknown") + "\""
let gitCommit: String = "\"" + (Context.gitInformation?.currentCommit ?? "unknown") + "\""

let package = Package(
    name: "Core",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Metadata",
            targets: ["Metadata"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/azooKey/AzooKeyKanaKanjiConverter", branch: "v0.8.0", traits: ["Zenzai"]),
    ],
    targets: [
        .target(
            name: "Metadata",
            cSettings: [
                .define(
                    "GIT_TAG", to: gitTag
                ),
                .define(
                    "GIT_COMMIT", to: gitCommit
                ),
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .target(name: "Metadata"),
                .product(name: "SwiftUtils", package: "AzooKeyKanaKanjiConverter"),
                .product(name: "KanaKanjiConverterModuleWithDefaultDictionary", package: "AzooKeyKanaKanjiConverter"),
            ],
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
