# PDFGadget

[![CI Build Status](https://github.com/orchetect/PDFGadget/actions/workflows/build.yml/badge.svg)](https://github.com/orchetect/PDFGadget/actions/workflows/build.yml) [![Platforms - macOS 10.12+ | iOS 11+](https://img.shields.io/badge/platforms-macOS%2010.12+%20|%20iOS%2011+-lightgrey.svg?style=flat)](https://developer.apple.com/swift) ![Swift 5.6-5.8](https://img.shields.io/badge/Swift-5.6–5.8-orange.svg?style=flat) [![Xcode 13.3-14](https://img.shields.io/badge/Xcode-13.3–14-blue.svg?style=flat)](https://developer.apple.com/swift) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/PDFGadget/blob/main/LICENSE)

Batch PDF utilities with simple API for Swift. Declarative API for:

- assigning or remove file metadata
- file filtering, ordering, and merging
- page management: reordering, collation, copying, moving, and replacement
- page presentation: rotation, cropping, etc.
- page content: filtering or removal of annotations

> **Note**: *(Currently only a Swift library. CLI and/or GUI frontend may be added in future.)*

## Basic Usage

```swift
import PDFGadget

let sources = [URL, URL, URL, ...] // URLs to one or more PDF files
let outputDir = URL.desktopFolder
```

The steps of loading source PDFs, performing operations, and saving the resulting PDFs can be performed individually:

```swift
let pdfGadget = PDFGadget()

try pdfGadget.load(pdfs: sources)
try pdfGadget.perform(operations: [
    // one or more operations
])

// access the resulting PDF documents in memory
pdfGadget.pdfDocuments // [PDFDocument]

// or save them as PDF files to disk
try pdfGadget.savePDFs(outputDir: outputDir)
```
Or a fully automated batch operation can be run with a single call to `run()` by passing in a populated instance of `PDFGadget.Settings`.

```swift
let settings = PDFGadget.Settings(
    sourcePDFs: sources,
    outputDir: outputDir,
    operations: [
        // one or more operations
    ],
    savePDFs: true
)

try PDFGadget().run(using: settings)
```

## Batch Operations

The following are single operations that may be used in a batch sequence of operations.

>  **Note**: More to be added in future, including: page cropping, more sophisticated annotation editing/filtering/removal.

### File Operations

- New empty file
- Clone file
- Filter files
- Merge files
- Set file filename
- Set or remove file attributes (metadata such as title, author, etc.)

### Page Operations

- Filter pages
- Copy pages
- Move pages
- Replace pages by copying or moving them
- Reverse page order (all or subset of pages)
- Rotate pages
- Split file into multiple files

### Page Content Operations

- Filter annotations (by types, or remove all)

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](/LICENSE) for details.

## Sponsoring

If you enjoy using PDFGadget and want to contribute to open-source financially, GitHub sponsorship is much appreciated. Feedback and code contributions are also welcome.

## Roadmap & Contributions

Planned and in-progress features can be found in [Issues](https://github.com/orchetect/PDFGadget/issues). Any help is welcome and appreciated.
