# swift-pdf-processor

[![Platforms - macOS 11+ | iOS 14+ | visionOS 1+](https://img.shields.io/badge/platforms-macOS%2011+%20|%20iOS%2014+%20|%20visionOS%201+-lightgrey.svg?style=flat)](https://developer.apple.com/swift) ![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat) [![Xcode 16](https://img.shields.io/badge/Xcode-16-blue.svg?style=flat)](https://developer.apple.com/swift) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/swift-pdf-processor/blob/main/LICENSE)

Batch PDF utilities with simple API for Swift. Declarative API for:

- assigning or removing file attributes (metadata)
- file filtering, ordering, and merging
- page management: reordering, collation, copying, moving, and replacement
- page presentation: rotation, cropping, etc.
- page content: filtering, removal or burn-in of annotations, removal of file protections

## Installation

### Swift Package Manager (SPM)

To add this package to an Xcode app project, use:

 `https://github.com/orchetect/swift-pdf-processor` as the URL.

To add this package to a Swift package, add the dependency to your package and target in Package.swift:

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-pdf-processor", from: "0.3.0")
    ],
    targets: [
        .target(
            dependencies: [
                .product(name: "PDFProcessor", package: "swift-pdf-processor")
            ]
        )
    ]
)
```

## Basic Usage

```swift
import PDFProcessor

let sources = [URL, URL, URL, ...] // URLs to one or more PDF files
let outputDir = URL.desktopDirectory
```

The steps of loading source PDFs, performing operations, and saving the resulting PDFs can be performed individually:

```swift
let processor = PDFProcessor()

try processor.load(pdfs: sources)
try processor.perform(operations: [
    // one or more operations
])

// access the resulting PDF documents in memory
processor.pdfDocuments // [PDFDocument]

// or save them as PDF files to disk
try processor.savePDFs(outputDir: outputDir)
```

Or a fully automated batch operation can be run with a single call to `run()` by passing in a populated instance of `PDFProcessor.Settings`.

```swift
let settings = try PDFProcessor.Settings(
    sourcePDFs: sources,
    outputDir: outputDir,
    operations: [
        // one or more operations
    ],
    savePDFs: true
)

try PDFProcessor().run(using: settings)
```

## Batch Operations

The following are single operations that may be used in a batch sequence of operations.

> [!NOTE]
> More operations may be added in future on an as-needed basis.

### File Operations

- New empty file
- Clone file
- Filter files
- Merge files
- Set file filename(s)
- Set or remove file attributes (metadata such as title, author, etc.)
- Remove file protections (encryption and permissions)

### Page Operations

- Filter pages
- Copy pages
- Move pages
- Replace pages by copying or moving them
- Reverse page order (all or subset of pages)
- Rotate pages
- Crop pages
- Split file into multiple files

### Page Content Operations

- Filter annotations (by types, or remove all)
- Burn in annotations
- Extract plain text (to system pasteboard, to file on disk, or to variable in memory)

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](/LICENSE) for details.

## Sponsoring

If you enjoy using swift-pdf-processor and want to contribute to open-source financially, GitHub sponsorship is much appreciated. Feedback and code contributions are also welcome.

## Community & Support

Please do not email maintainers for technical support. Several options are available for issues and questions:

- Questions and feature ideas can be posted to [Discussions](https://github.com/orchetect/swift-pdf-processor/discussions).
- If an issue is a verifiable bug with reproducible steps it may be posted in [Issues](https://github.com/orchetect/swift-pdf-processor/issues).

## Contributions

Contributions are welcome. Posting in [Discussions](https://github.com/orchetect/swift-pdf-processor/discussions) first prior to new submitting PRs for features or modifications is encouraged.

## Legacy

This repository was formerly known as PDFGadget.
