//
//  DevTests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import XCTest
@testable import PDFGadgetLib
@_implementationOnly import OTCore

/// DEV TESTS
/// These are not unit tests. They are experimental and only used during development.

final class PDFGadgetLibTests: XCTestCase {
//    func testNewFeature() throws {
//        let run = false // ⚠️ protection!!
//        guard run else { return }
//        
//        let desktop = URL.desktopDirectoryBackCompat
//        
//        let sources: [URL] = [
//            desktop.appendingPathComponent("Test1.pdf") //,
//            //            desktop.appendingPathComponent("Test2.pdf")
//        ]
//        
//        try PDFGadget().run(using: PDFGadget.Settings(
//            sourcePDFs: sources,
//            outputDir: nil,
//            operations: [
//                .filterFiles(.all),
//                .filterFiles(.filename(.equals("Test2")))
//                .filterFiles(.introspecting(.init(description: "Test", closure: { pdf in
//                    pdf.documentURL?.lastPathComponent == "Test2.pdf"
//                })))
//                .mergeFiles(.first, appendingTo: .second)
//                .movePages(fromFile: .first,
//                           fromPages: .include([.first(count: 3)]),
//                           toFile: .first,
//                           toPageIndex: 5),
//                .filterFiles(.first)
//                .cloneFile(file: .first)
//                .reversePageOrder(file: .first, pages: .include([.range(indexes: 6...22)]))
//                .newFile,
//                .copyPages(fromFile: .first, fromPages: .include([.first(count: 3)]), toFile: .second),
//                .movePages(fromFile: .first, fromPages: .include([.last(count: 3)]), toFile: .second),
//                .filterFiles(.second)
//                .cropPages(file: .first,
//                           pages: .include([.first(count: 3)]),
//                           area: .scale(factor: 0.5),
//                           process: .relative)
//                .setFilename(file: .first, filename: "first"),
//                .setFilename(file: .second, filename: "second")
//                .splitFile(file: .first, .at(pageIndexes: [4, 20, 22]))
//                ,
//                .splitFile(file: .first, .every(pageCount: 10))
//                ,
//                .splitFile(file: .first, .pageIndexesAndFilenames([0...4: "one", 5...20: "two", 21...22: "three", 23...24: "four"]))
//                .splitFile(file: .first, .pageNumbersAndFilenames([1...5: "one", 6...21: "two", 22...23: "three", 24...25: "four"]))
//                .splitFile(
//                    file: .first,
//                    discardUnused: false,
//                    .pageNumbersAndFilenames([
//                        .init(1 ... 5, "one"),
//                        .init(6 ... 21, "two"),
//                        //                      .init(22 ... 23, "three"),
//                        .init(24 ... 25, "four")
//                    ])
//                )
//                
//            ],
//            savePDFs: true
//        ))
//    }
    
//    func testCollate() throws {
//        let run = false // ⚠️ protection!!
//        guard run else { return }
//        
//        let desktop = URL.desktopDirectoryBackCompat
//        
//        let subDir = desktop.appendingPathComponent("Scans")
//        
//        let sources: [URL] = [
//            subDir.appendingPathComponent("1A.pdf"),
//            subDir.appendingPathComponent("1B.pdf")
//        ]
//        
//        try PDFGadget().run(using: PDFGadget.Settings(
//            sourcePDFs: sources,
//            outputDir: desktop,
//            operations: [
//                .reversePageOrder(file: .second, pages: .all),
//                .replacePages(
//                    fromFile: .second,
//                    fromPages: .include([.evenNumbers]),
//                    toFile: .first,
//                    toPages: .include([.evenNumbers]),
//                    behavior: .copy
//                ),
//                .filterFiles(.first)
//            ],
//            savePDFs: true
//        ))
//    }
    
//    func testStitchFiles() throws {
//        let run = false // ⚠️ protection!!
//        guard run else { return }
//        
//        let desktop = URL.desktopDirectoryBackCompat
//        
//        let subDir = desktop.appendingPathComponent("Scans")
//        
//        let sources: [URL] = (2...11).map {
//            subDir.appendingPathComponent("\($0).pdf")
//        }
//        
//        try PDFGadget().run(using: PDFGadget.Settings(
//            sourcePDFs: sources,
//            outputDir: desktop,
//            operations: [
//                .mergeFiles()
//            ],
//            savePDFs: true
//        ))
//    }
    
//    func testSplitFiles() throws {
//        let run = false // ⚠️ protection!!
//        guard run else { return }
//        
//        let desktop = URL.desktopDirectoryBackCompat
//        
//        let subDir = desktop.appendingPathComponent("Scans")
//        let sources = [subDir.appendingPathComponent("Pages.pdf")]
//        
//        try PDFGadget().run(using: PDFGadget.Settings(
//            sourcePDFs: sources,
//            outputDir: desktop.appendingPathComponent("Output"),
//            operations: [
//                .splitFile(file: .first, discardUnused: false, .pageNumbersAndFilenames([
//                    .init(1...1, "1m1A"),
//                    .init(1...25, "1m1B"),
//                    .init(26...28, "1m2"),
//                    .init(29...46, "1m3R"),
//                    .init(46...51, "1m4-2m1"),
//                    .init(52...60, "2m2"),
//                    .init(61...72, "3m3"),
//                    .init(73...74, "3m2"), // out of order in book!
//                    .init(75...80, "3m1"), // out of order in book!
//                    .init(81...82, "4m1-alt"),
//                    .init(83...83, "4m1"),
//                    .init(84...84, "4m1A"),
//                    .init(85...86, "4m2A"),
//                    .init(87...91, "4m2"),
//                    .init(92...92, "4m2B"),
//                    .init(92...93, "5m1A"),
//                    .init(93...103, "5m1S-5m2S"),
//                    .init(103...109, "5m1B"),
//                    .init(110...111, "5m2"),
//                    .init(112...116, "6m1"),
//                    .init(117...118, "6m1A"),
//                    .init(119...121, "6m3"),
//                    .init(122...123, "6m2"), // out of order in book!
//                    .init(123...123, "6m2A"),
//                    .init(123...123, "7m1"),
//                    .init(124...126, "7m2"),
//                    .init(127...136, "7m2A"),
//                    .init(137...148, "8m1"),
//                    .init(149...151, "8m1A"),
//                    .init(152...154, "9m1"),
//                    .init(155...157, "9m2"),
//                    .init(158...158, "10m1-10m2"),
//                    .init(159...170, "10m3"),
//                    .init(171...184, "10m4"),
//                    .init(185...222, "11m1"),
//                    .init(222...226, "11m2"),
//                    .init(227...247, "12m1"),
//                    .init(248...254, "12m2R"),
//                    .init(255...259, "13m1R"),
//                    .init(260...263, "13m2"),
//                    .init(264...265, "13m2A"),
//                    .init(266...267, "13m2A-alt"),
//                    .init(268...269, "14m1A"),
//                    .init(270...277, "14m1"),
//                    .init(278...309, "14m2")
//                ]))
//            ],
//            savePDFs: true
//        ))
//    }
}

