# PDFGadget

Batch PDF utilities with simple API for Swift.

*(Currently only a Swift library. CLI and/or GUI frontend may be added in future.)*

## Basic Usage

```swift
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

The following are single operations that may be used in a batch sequence of operations. More to be added in future.

### File Operations

- New empty file
- Clone file
- Filter files
- Merge files
- Set file's filename

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
