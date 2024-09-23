//
//  DevTests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if os(macOS)

import XCTest
@testable import PDFGadgetLib
import PDFKit
import OTCore

/// DEV TESTS
/// These are not unit tests. They are experimental and only used during development.

// MARK: - Boilerplate

final class DevTests: XCTestCase {
    static let desktop = URL.desktopDirectoryBackCompat
    
    func skipWithoutShift() throws {
        try XCTSkipUnless(
            NSEvent.modifierFlags.contains(.shift),
            "Failsafe protection. Hold SHIFT key to allow test to run."
        )
    }
}

// MARK: - Scripts

extension DevTests {
    func testExtractPlainText() throws {
        try skipWithoutShift()
        
        let sources: [URL] = [
            Self.desktop.appendingPathComponent("1.pdf")
        ]
        
        let outputDir = Self.desktop
        let outputTextFile = outputDir.appendingPathComponent("1.txt")
        
        // let textVar = "TEXT"
        
        let settings = try PDFGadget.Settings(
            sourcePDFs: sources,
            outputDir: outputDir,
            operations: [
                .extractPlainText(
                    file: .first,
                    pages: .all, 
                    to: .file(url: outputTextFile), // .variable(named: textVar),
                    pageBreak: .doubleNewLine
                )
            ],
            savePDFs: false
        )
        
        let gadget = PDFGadget()
        
        try gadget.run(using: settings)
        
        // debug, if using .variable(named:) extractPlainText operation
        // let extractedText = try XCTUnwrap(gadget.variables[textVar])
        // print(extractedText)
    }
    
    // /// Removes footer elements from invoices generated with Zoho Invoice.
    // func testCleanInvoice() throws {
    //     try skipWithoutShift()
    //
    //     let sources: [URL] = [
    //         Self.desktop.appendingPathComponent("TestInvoice.pdf")
    //     ]
    //
    //     let outputDir = Self.desktop
    //
    //     let settings = try PDFGadget.Settings(
    //         sourcePDFs: sources,
    //         outputDir: outputDir,
    //         operations: [
    //             .filterObjects(files: .all, pages: .all, within: nil)
    //         ],
    //         savePDFs: false
    //     )
    //
    //     let gadget = PDFGadget()
    //
    //     try gadget.run(using: settings)
    //
    //     // let p = PDFPage()
    //     // let b = PDFDisplayBox.cropBox
    //     //
    //     // let d = try XCTUnwrap(p.dataRepresentation)
    //     // try d.write(to: outputDir.appendingPathComponent("raw-pdf-page.bin"))
    //
    //     // let c = CGContext()
    //     // p.draw(with: .cropBox, to: c)
    // }
    
    /// For paper score scanning, this method performs a collated page swap between two PDF files.
    /// This expects pairs of PDF files named 1A, 1B, 2A, 2B, etc.
    ///
    /// - Note: Update the integer range before running.
    func testCollate() throws {
        try skipWithoutShift()
        
        let subDir = Self.desktop.appendingPathComponent("Scans")
        
        let i = 13
        for num in i...i { // ⚠️ Update this range before running
            let sources: [URL] = [
                subDir.appendingPathComponent("\(num)A.pdf"),
                subDir.appendingPathComponent("\(num)B.pdf")
            ]
            
            try collateScore(sources: sources, outputFilename: "\(num)", outputDir: Self.desktop)
        }
        
        func collateScore(sources: [URL], outputFilename: String, outputDir: URL) throws {
            let settings = try PDFGadget.Settings(
                sourcePDFs: sources,
                outputDir: outputDir,
                operations: [
                    .reversePageOrder(file: .second, pages: .all),
                    .replacePages(
                        fromFile: .second,
                        fromPages: .include([.evenNumbers]),
                        toFile: .first,
                        toPages: .include([.evenNumbers]),
                        behavior: .copy
                    ),
                    .filterFiles(.first),
                    .setFilename(file: .first, filename: outputFilename)
                ],
                savePDFs: true
            )
            
            try PDFGadget().run(using: settings)
        }
    }
    
    /// Merges/combines a series of sequentially numbered PDFs into a single PDF.
    ///
    /// - Note: Update the integer range before running.
    func testStitchFiles() throws {
        try skipWithoutShift()
        
        let subDir = Self.desktop.appendingPathComponent("Scans")
        
        let sources: [URL] = (2...7).map { // ⚠️ Update this range before running
            subDir.appendingPathComponent("\($0).pdf")
        }
        
        let settings = try PDFGadget.Settings(
            sourcePDFs: sources,
            outputDir: Self.desktop,
            operations: [
                .mergeFiles(),
                .setFilename(file: .first, filename: "Combined")
            ],
            savePDFs: true
        )
        
        try PDFGadget().run(using: settings)
    }
    
    /// Takes a single PDF file containing all pages of a print score and splits it into individual PDF files.
    func testSplitFiles() throws {
        try skipWithoutShift()
        
        let subDir = Self.desktop.appendingPathComponent("Scans")
        let sources = [subDir.appendingPathComponent("Combined.pdf")]
        
        let settings = try PDFGadget.Settings(
            sourcePDFs: sources,
            outputDir: Self.desktop.appendingPathComponent("Output"),
            operations: [
                .splitFile(file: .first, discardUnused: false, .pageNumbersAndFilenames([
                    .init(1...1, "R1PA Warner Bros. Signature"),
                    .init(2...4, "R1P1 The Shop"),
                    .init(5...9, "R1P2 The Little One"),
                    .init(10...17, "R1P4-R2P1 Late for Work"),
                    .init(18...22, "R2P2 Mrs. Deagle"), // partial end page
                    .init(22...25, "R2P3 That Dog"), // partial start page
                    .init(26...29, "R3P3 The Gift"),
                    .init(30...33, "R3P5 First Aid"), // partial end page
                    .init(33...39, "R3P7 Spilt Water"), // partial start page
                    .init(40...41, "R4P2 A New One"),
                    .init(42...46, "R4P3 The Lab"),
                    .init(47...50, "R4P4 Old Times"),
                    .init(51...55, "R5P2 The Injection"), // partial end page
                    .init(55...56, "R5P5 Snack Time"), // partial start page
                    .init(57...58, "R5P7 The Wrong Time"),
                    .init(59...64, "R6P1 The Box"),
                    .init(65...70, "R6P2 First Aid"), // partial end page
                    .init(70...71, "R6P3 Disconnected"), // partial start page
                    .init(72...72, "R6P5 Hurry Home"),
                    .init(73...92, "R7P2 Kitchen Fight"),
                    .init(93...93, "R7P3 Dirty Linen"),
                    .init(94...95, "R7P4 The Pool"),
                    .init(96...98, "R7P5 God Rest You Merry Gentlemen"), // partial end page
                    .init(98...100, "R8P2 The Plow"), // partial start page
                    .init(101...105, "R8P3 Special Delivery"),
                    .init(106...114, "R8P4 High Flyer"),
                    .init(115...120, "R8P5 Too Many Gremlins"),
                    .init(121...129, "R9P3 No Santa Claus"),
                    .init(130...132, "R10P1 After Theater"), // partial end page
                    .init(132...137, "R10P3 Theater Escape"), // partial start page
                    .init(138...145, "R10P4 Stripe is Loose"),
                    .init(146...146, "R11P1 Toy Dept"),
                    .init(147...147, "R11P2 O Tannenbaum"),
                    .init(148...149, "R11P3 No Gizmo"),
                    .init(150...178, "R11P4 The Fountain"),
                    .init(179...182, "R12P1 Stripe's Death"),
                    .init(183...187, "R12P2 Goodbye Billy"),
                    .init(188...192, "R12P3 End Title") // + 2 pages (193, 194)
                ]))
            ],
            savePDFs: true
        )
        
        try PDFGadget().run(using: settings)
    }
    
    // Conan the Barbarian (Basil P.):
    // operations: [
    //     .splitFile(file: .first, discardUnused: false, .pageNumbersAndFilenames([
    //         .init(1...1, "1m1A"),
    //         .init(1...25, "1m1B"),
    //         .init(26...28, "1m2"),
    //         .init(29...46, "1m3R"),
    //         .init(46...51, "1m4-2m1"),
    //         .init(52...60, "2m2"),
    //         .init(61...72, "3m3"),
    //         .init(73...74, "3m2"), // out of order in book!
    //         .init(75...80, "3m1"), // out of order in book!
    //         .init(81...82, "4m1-alt"),
    //         .init(83...83, "4m1"),
    //         .init(84...84, "4m1A"),
    //         .init(85...86, "4m2A"),
    //         .init(87...91, "4m2"),
    //         .init(92...92, "4m2B"),
    //         .init(92...93, "5m1A"),
    //         .init(93...103, "5m1S-5m2S"),
    //         .init(103...109, "5m1B"),
    //         .init(110...111, "5m2"),
    //         .init(112...116, "6m1"),
    //         .init(117...118, "6m1A"),
    //         .init(119...121, "6m3"),
    //         .init(122...123, "6m2"), // out of order in book!
    //         .init(123...123, "6m2A"),
    //         .init(123...123, "7m1"),
    //         .init(124...126, "7m2"),
    //         .init(127...136, "7m2A"),
    //         .init(137...148, "8m1"),
    //         .init(149...151, "8m1A"),
    //         .init(152...154, "9m1"),
    //         .init(155...157, "9m2"),
    //         .init(158...158, "10m1-10m2"),
    //         .init(159...170, "10m3"),
    //         .init(171...184, "10m4"),
    //         .init(185...222, "11m1"),
    //         .init(222...226, "11m2"),
    //         .init(227...247, "12m1"),
    //         .init(248...254, "12m2R"),
    //         .init(255...259, "13m1R"),
    //         .init(260...263, "13m2"),
    //         .init(264...265, "13m2A"),
    //         .init(266...267, "13m2A-alt"),
    //         .init(268...269, "14m1A"),
    //         .init(270...277, "14m1"),
    //         .init(278...309, "14m2")
    //     ]))
    // ]
    
    // Total Recall (Jerry Goldsmith)
    // operations: [
    //     .splitFile(file: .first, discardUnused: false, .pageNumbersAndFilenames([
    //         .init(1...15, "1m1"),
    //         .init(16...18, "1m1A"),
    //         .init(19...21, "1m4-2m1"),
    //         .init(22...22, "2m5"),
    //         .init(23...33, "2m6"), // partial end page
    //         .init(33...35, "3m1"), // partial start page
    //         .init(36...36, "3m2"),
    //         .init(37...51, "3m3"),
    //         .init(52...76, "3m4-4m1"),
    //         .init(77...95, "4m4"),
    //         .init(96...101, "5m1"),
    //         .init(102...110, "5m1A"),
    //         .init(111...112, "5m2"),
    //         .init(113...123, "5m3"),
    //         .init(124...127, "5m4-6m1"), // partial end page
    //         .init(127...128, "6m3"), // partial start page, partial end page
    //         .init(128...129, "7m2"), // partial start page
    //         .init(130...134, "7m4"),
    //         .init(135...150, "7m5-8m1"),
    //         .init(151...181, "8m2"),
    //         .init(182...182, "8m3"),
    //         .init(183...185, "9m1"), // partial end page
    //         .init(185...193, "9m2"), // partial start page
    //         .init(194...204, "9m3"),
    //         .init(205...209, "10m1"),
    //         .init(210...239, "10m2-11m1"),
    //         .init(240...242, "11m2"),
    //         .init(243...265, "11m3-12m1"),
    //         .init(266...302, "12m2"),
    //         .init(303...306, "12m3"),
    //         .init(307...324, "12m4")
    //     ])),
    //     .setFilenames(filenames: [
    //         "JG_TotalRecall_1m1 The Dream",
    //         "JG_TotalRecall_1m1A Titles - Film Ending",
    //         "JG_TotalRecall_1m4-2m1 First Meeting",
    //         "JG_TotalRecall_2m5 Secret Agent",
    //         "JG_TotalRecall_2m6 The Implant",
    //         "JG_TotalRecall_3m1 Where Am I",
    //         "JG_TotalRecall_3m2 The Aftermath",
    //         "JG_TotalRecall_3m3 Old Time's Sake",
    //         "JG_TotalRecall_3m4-4m1 Clever Girl",
    //         "JG_TotalRecall_4m4 The Johnny Cab",
    //         "JG_TotalRecall_5m1 Howdy Stranger",
    //         "JG_TotalRecall_5m1A The Nose Job",
    //         "JG_TotalRecall_5m2 The Spaceport",
    //         "JG_TotalRecall_5m3 A New Face",
    //         "JG_TotalRecall_5m4-6m1 The Mountain",
    //         "JG_TotalRecall_6m3 Identification",
    //         "JG_TotalRecall_7m2 Lies",
    //         "JG_TotalRecall_7m4 Where Am I",
    //         "JG_TotalRecall_7m5-8m1 Swallow It",
    //         "JG_TotalRecall_8m2 The Big Jump",
    //         "JG_TotalRecall_8m3 Without Air",
    //         "JG_TotalRecall_9m1 Remembering",
    //         "JG_TotalRecall_9m2 The Mutant",
    //         "JG_TotalRecall_9m3 The Massacre",
    //         "JG_TotalRecall_10m1 Friends",
    //         "JG_TotalRecall_10m2-11m1 The Treatment",
    //         "JG_TotalRecall_11m2 The Reactor",
    //         "JG_TotalRecall_11m3-12m1 The Hologram",
    //         "JG_TotalRecall_12m2 End of A Dream",
    //         "JG_TotalRecall_12m3 A New Life",
    //         "JG_TotalRecall_12m4 End Credits"
    //     ])
    // ]
    
    // Gremlins (Jerry Goldsmith)
    // operations: [
    //     .splitFile(file: .first, discardUnused: false, .pageNumbersAndFilenames([
    //         .init(1...1, "R1PA Warner Bros. Signature"),
    //         .init(2...4, "R1P1 The Shop"),
    //         .init(5...9, "R1P2 The Little One"),
    //         .init(10...17, "R1P4-R2P1 Late for Work"),
    //         .init(18...22, "R2P2 Mrs. Deagle"), // partial end page
    //         .init(22...25, "R2P3 That Dog"), // partial start page
    //         .init(26...29, "R3P3 The Gift"),
    //         .init(30...33, "R3P5 First Aid"), // partial end page
    //         .init(33...39, "R3P7 Spilt Water"), // partial start page
    //         .init(40...41, "R4P2 A New One"),
    //         .init(42...46, "R4P3 The Lab"),
    //         .init(47...50, "R4P4 Old Times"),
    //         .init(51...55, "R5P2 The Injection"), // partial end page
    //         .init(55...56, "R5P5 Snack Time"), // partial start page
    //         .init(57...58, "R5P7 The Wrong Time"),
    //         .init(59...64, "R6P1 The Box"),
    //         .init(65...70, "R6P2 First Aid"), // partial end page
    //         .init(70...71, "R6P3 Disconnected"), // partial start page
    //         .init(72...72, "R6P5 Hurry Home"),
    //         .init(73...92, "R7P2 Kitchen Fight"),
    //         .init(93...93, "R7P3 Dirty Linen"),
    //         .init(94...95, "R7P4 The Pool"),
    //         .init(96...98, "R7P5 God Rest You Merry Gentlemen"), // partial end page
    //         .init(98...100, "R8P2 The Plow"), // partial start page
    //         .init(101...105, "R8P3 Special Delivery"),
    //         .init(106...114, "R8P4 High Flyer"),
    //         .init(115...120, "R8P5 Too Many Gremlins"),
    //         .init(121...129, "R9P3 No Santa Claus"),
    //         .init(130...132, "R10P1 After Theater"), // partial end page
    //         .init(132...137, "R10P3 Theater Escape"), // partial start page
    //         .init(138...145, "R10P4 Stripe is Loose"),
    //         .init(146...146, "R11P1 Toy Dept"),
    //         .init(147...147, "R11P2 O Tannenbaum"),
    //         .init(148...149, "R11P3 No Gizmo"),
    //         .init(150...178, "R11P4 The Fountain"),
    //         .init(179...182, "R12P1 Stripe's Death"),
    //         .init(183...187, "R12P2 Goodbye Billy"),
    //         .init(188...192, "R12P3 End Title")
    //     ]))
    // ]
}

// MARK: - Zoho Invoice Footer Removal

// Note: Used with "filterObjects WIP" git stash

extension DevTests {
    // func testInvoiceFooterRemoval() throws {
    //     try skipWithoutShift()
    //
    //     let inputPDFURL = Self.desktop.appendingPathComponent("TestInvoice.pdf")
    //
    //     let settings = try PDFGadget.Settings(
    //         sourcePDFs: [inputPDFURL],
    //         outputDir: Self.desktop,
    //         operations: [
    //             .filterObjects(files: .all, pages: .all, within: nil) // TODO: temporary
    //         ],
    //         savePDFs: true
    //     )
    //
    //     try PDFGadget().run(using: settings)
    // }
}

// MARK: - Temporary Dev Tests

extension DevTests {
    // func testNewFeature() throws {
    //     try skipWithoutShift()
    //
    //     let sources: [URL] = [
    //         Self.desktop.appendingPathComponent("Test1.pdf") //,
    //         // Self.desktop.appendingPathComponent("Test2.pdf")
    //     ]
    //
    //     let settings = try PDFGadget.Settings(
    //         sourcePDFs: sources,
    //         outputDir: nil,
    //         operations: [
    //             .filterFiles(.all),
    //             .filterFiles(.filename(.equals("Test2"))),
    //             .filterFiles(.introspecting(.init(description: "Test", closure: { pdf in
    //                 pdf.documentURL?.lastPathComponent == "Test2.pdf"
    //             }))),
    //             .mergeFiles(.first, appendingTo: .second),
    //             .movePages(fromFile: .first,
    //                        fromPages: .include([.first(count: 3)]),
    //                        toFile: .first,
    //                        toPageIndex: 5),
    //             .filterFiles(.first),
    //             .cloneFile(file: .first),
    //             .reversePageOrder(file: .first, pages: .include([.range(indexes: 6...22)])),
    //             .newFile,
    //             .copyPages(fromFile: .first, fromPages: .include([.first(count: 3)]), toFile: .second),
    //             .movePages(fromFile: .first, fromPages: .include([.last(count: 3)]), toFile: .second),
    //             .filterFiles(.second),
    //             .cropPages(file: .first,
    //                        pages: .include([.first(count: 3)]),
    //                        area: .scale(factor: 0.5),
    //                        process: .relative),
    //             .setFilename(file: .first, filename: "first"),
    //             .setFilename(file: .second, filename: "second"),
    //             .splitFile(file: .first, .at(pageIndexes: [4, 20, 22])),
    //             .splitFile(file: .first, .every(pageCount: 10)),
    //             .splitFile(file: .first, .pageIndexesAndFilenames([0...4: "one", 5...20: "two", 21...22: "three", 23...24: "four"])),
    //             .splitFile(file: .first, .pageNumbersAndFilenames([1...5: "one", 6...21: "two", 22...23: "three", 24...25: "four"])),
    //             .splitFile(
    //                 file: .first,
    //                 discardUnused: false,
    //                 .pageNumbersAndFilenames([
    //                     .init(1 ... 5, "one"),
    //                     .init(6 ... 21, "two"),
    //                     //                      .init(22 ... 23, "three"),
    //                     .init(24 ... 25, "four")
    //                 ])
    //             )
    //
    //         ],
    //         savePDFs: true
    //     )
    //
    //     try PDFGadget().run(using: settings)
    // }
}

#endif
