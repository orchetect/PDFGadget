// swift-tools-version: 5.6
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "PDFGadget",
    platforms: [
        .macOS(.v10_12), .iOS(.v11)
    ],
    products: [
        .library(
            name: "PDFGadgetLib",
            type: .static,
            targets: ["PDFGadgetLib"]
        ),
        .executable(
            name: "pdfgadget",
            targets: ["pdfgadget-cli"]
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
            name: "PDFGadgetLib",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                // .product(name: "Collections", package: "swift-collections"),
                .product(name: "OTCore", package: "OTCore")
            ]
        ),
        .testTarget(
            name: "PDFGadgetLibTests",
            dependencies: ["PDFGadgetLib"],
            resources: [.copy("TestResource/PDF Files")]
        ),
        .executableTarget(
            name: "pdfgadget-cli",
            dependencies: [
                "PDFGadgetLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
