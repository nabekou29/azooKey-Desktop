// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/azooKey/AzooKeyKanaKanjiConverter", branch: "ee14c15ae9970c74a7a958aece64593ff1988141", traits: ["Zenzai"])
    ],
    targets: [
        .executableTarget(
            name: "git-info-generator"
        ),
        .plugin(
            name: "GitInfoPlugin",
            capability: .buildTool(),
            dependencies: [.target(name: "git-info-generator")]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "SwiftUtils", package: "AzooKeyKanaKanjiConverter"),
                .product(name: "KanaKanjiConverterModuleWithDefaultDictionary", package: "AzooKeyKanaKanjiConverter")
            ],
            plugins: [
                .plugin(name: "GitInfoPlugin")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        )
    ]
)
