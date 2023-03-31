//
//  PDFToolTests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib
import OTCore

final class PDFToolLibTests: XCTestCase {
    func testNewFeature() throws {
        let run = false // ⚠️ protection!!
        guard run else { return }
        
        let desktop = URL.desktopDirectoryBackCompat
        
        let sources: [URL] = [
            desktop.appendingPathComponent("Test1.pdf") //,
//            desktop.appendingPathComponent("Test2.pdf")
        ]
        
        try PDFTool().run(using: PDFTool.Settings(
            sourcePDFs: sources,
            outputDir: nil,
            operations: [
//                .filterFiles(.all)
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
                .newFile,
                .copyPages(fromFile: .first, fromPages: .include([.first(count: 3)]), toFile: .second, toPageIndex: 0),
                .filterFiles(.second)
            ],
            outputBaseFilenamesWithoutExtension: nil, // ["FooA", "FooB", "FooC"],
            savePDFs: true
        ))
    }
    
    func testRunner() throws {
        let run = false // ⚠️ protection!!
        guard run else { return }
        
        let desktop = URL.desktopDirectoryBackCompat
        
        let subDir = desktop.appendingPathComponent("Scans")
        
        let sources: [URL] = [
            subDir.appendingPathComponent("1A.pdf"),
            subDir.appendingPathComponent("1B.pdf")
        ]
        
        try PDFTool().run(using: PDFTool.Settings(
            sourcePDFs: sources,
            outputDir: desktop,
            operations: [
                .reversePageOrder(file: .second, pages: .all),
                .replacePages(
                    fromFile: .second,
                    fromPages: .include([.evenNumbers]),
                    toFile: .first,
                    toPages: .include([.evenNumbers]),
                    behavior: .copy
                ),
                .filterFiles(.first)
            ],
            outputBaseFilenamesWithoutExtension: nil,
            savePDFs: true
        ))
    }
}
