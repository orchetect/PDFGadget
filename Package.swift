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
            name: "PDFGadgetLib",
            type: .static,
            targets: ["PDFGadgetLib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/OTCore.git", from: "1.7.6"),
        .package(url: "https://github.com/orchetect/swift-testing-extensions.git", from: "0.2.1")
    ],
    targets: [
        .target(
            name: "PDFGadgetLib",
            dependencies: [
                "OTCore"
            ]
        ),
        .testTarget(
            name: "PDFGadgetLibTests",
            dependencies: [
                "OTCore",
                "PDFGadgetLib",
                .product(name: "TestingExtensions", package: "swift-testing-extensions")
            ],
            resources: [.copy("TestResource/PDF Files")]
        )
    ]
)
