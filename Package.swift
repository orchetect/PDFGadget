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
            name: "PDFToolLib",
            type: .static,
            targets: ["PDFToolLib"]
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
        .package(url: "https://github.com/orchetect/OTCore.git", from: "1.4.8")
    ],
    targets: [
        .target(
            name: "PDFToolLib",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                // .product(name: "Collections", package: "swift-collections"),
                .product(name: "OTCore", package: "OTCore")
            ]
        ),
        .testTarget(
            name: "PDFToolLibTests",
            dependencies: ["PDFToolLib"],
            resources: [.copy("TestResource/PDF Files")]
        ),
        .executableTarget(
            name: "pdftool-cli",
            dependencies: [
                "PDFToolLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
