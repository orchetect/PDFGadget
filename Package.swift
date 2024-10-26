// swift-tools-version: 5.6
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "PDFGadget",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)
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
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/orchetect/OTCore.git", from: "1.6.0"),
        .package(url: "https://github.com/orchetect/swift-testing-extensions.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "PDFGadgetLib",
            dependencies: [
                // .product(name: "Collections", package: "swift-collections"),
                .product(name: "OTCore", package: "OTCore")
            ]
        ),
        .testTarget(
            name: "PDFGadgetLibTests",
            dependencies: [
                "PDFGadgetLib",
                .product(name: "TestingExtensions", package: "swift-testing-extensions")
            ],
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
