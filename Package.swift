// swift-tools-version: 6.0
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "PDFGadget",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "PDFGadget",
            targets: ["PDFGadget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-extensions", from: "2.0.0"),
        .package(url: "https://github.com/orchetect/swift-testing-extensions.git", from: "0.2.4")
    ],
    targets: [
        .target(
            name: "PDFGadget",
            dependencies: [
                .product(name: "SwiftExtensions", package: "swift-extensions")
            ]
        ),
        .testTarget(
            name: "PDFGadgetTests",
            dependencies: [
                "PDFGadget",
                .product(name: "SwiftExtensions", package: "swift-extensions"),
                .product(name: "TestingExtensions", package: "swift-testing-extensions")
            ],
            resources: [.copy("TestResource/PDF Files")]
        )
    ]
)
