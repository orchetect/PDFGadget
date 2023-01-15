// swift-tools-version: 5.6
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "PDFTool",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "PDFTool",
            type: .static,
            targets: ["PDFTool"]
        ),
        .executable(
            name: "pdftool",
            targets: ["pdftool-cli"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        // .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/orchetect/OTCore.git", from: "1.4.5")
    ],
    targets: [
        .target(
            name: "PDFTool",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                // .product(name: "Collections", package: "swift-collections"),
                .product(name: "OTCore", package: "OTCore")
            ]
        ),
        .testTarget(
            name: "PDFToolTests",
            dependencies: ["PDFTool"]
        ),
        .executableTarget(
            name: "pdftool-cli",
            dependencies: [
                "PDFTool",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
