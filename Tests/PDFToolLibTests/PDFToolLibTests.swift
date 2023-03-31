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
        let run = true // ⚠️ protection!!
        guard run else { return }
        
        let desktop = FileManager.homeDirectoryForCurrentUserCompat
            .appendingPathComponent("Desktop")
        
        let sources: [URL] = [
            desktop.appendingPathComponent("Test.pdf")
        ]
        
        try PDFTool.process(
            settings: PDFTool.Settings(
                sourcePDFs: sources,
                outputDir: nil,
                operations: [
                    .filterAnnotations(
                        fileIndex: 0,
                        pages: .all, //.include([.pages(indexes: [1])]),
                        annotations: .exclude([.square]) // .exclude([.text, .freeText])
                    )
                ],
                outputBaseFileNameWithoutExtension: nil
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
                    .reversePageOrder(fileIndex: 1),
                    .replacePages(
                        fromFileIndex: 1,
                        fromPages: .include([.even]),
                        toFileIndex: 0,
                        toPages: .include([.even])
                    )
                ],
                outputBaseFileNameWithoutExtension: nil
            )
        )
    }
}
