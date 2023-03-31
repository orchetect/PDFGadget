//
//  PDFToolTests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib
import OTCore

final class PDFToolLibTests: XCTestCase {
    func testEmpty() throws {
        // empty
    }
    
    func testNewFeature() throws {
        let run = false // ⚠️ protection!!
        guard run else { return }
        
        let desktop = FileManager.homeDirectoryForCurrentUserCompat
            .appendingPathComponent("Desktop")
        
        let sources: [URL] = [
            desktop.appendingPathComponent("Test1.pdf"),
            desktop.appendingPathComponent("Test2.pdf")
        ]
        
        try PDFTool.process(
            settings: PDFTool.Settings(
                sourcePDFs: sources,
                outputDir: nil,
                operations: [
//                    .filterFiles(.all)
//                    .filterFiles(.filename(.equals("Test2")))
//                    .filterFiles(.introspecting(.init(description: "Test", closure: { pdf in
//                        pdf.documentURL?.lastPathComponent == "Test2.pdf"
//                    })))
//                    .mergeFiles(.first, appendingTo: .second)
                    .movePages(fromFile: .first,
                               fromPages: .only([.first(count: 3)]),
                               toFile: .first,
                               toPageIndex: 5),
                    .filterFiles(.first)
                ],
                outputBaseFileNamesWithoutExtension: nil // ["FooA", "FooB"]
            )
        )
    }
    
    func testRunner() throws {
        let run = false // ⚠️ protection!!
        guard run else { return }
        
        let desktop = FileManager.homeDirectoryForCurrentUserCompat
            .appendingPathComponent("Desktop")
        
        let subDir = desktop.appendingPathComponent("Scans")
        
        let sources: [URL] = [
            subDir.appendingPathComponent("1A.pdf"),
            subDir.appendingPathComponent("1B.pdf")
        ]
        
        try PDFTool.process(
            settings: PDFTool.Settings(
                sourcePDFs: sources,
                outputDir: desktop,
                operations: [
                    .reversePageOrder(file: .second),
                    .replacePages(
                        fromFile: .second,
                        fromPages: .only([.evenNumbers]),
                        toFile: .first,
                        toPages: .only([.evenNumbers]),
                        behavior: .copy
                    ),
                    .filterFiles(.first)
                ],
                outputBaseFileNamesWithoutExtension: nil
            )
        )
    }
}
