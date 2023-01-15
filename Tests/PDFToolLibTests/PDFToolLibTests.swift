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
    
    func testRunner() throws {
        let run = false // ⚠️ protection!!
        guard run else { return }
        
        let desktop = FileManager.homeDirectoryForCurrentUserCompat
            .appendingPathComponent("Desktop")
        
        let sources: [URL] = [
            desktop.appendingPathComponent("8A.pdf"),
            desktop.appendingPathComponent("8B.pdf")
        ]
        
        try PDFTool.process(
            settings: PDFTool.Settings(
                sourcePDFs: sources,
                outputDir: nil,
                operations: [
                    .reversePageOrder(fileIndex: 1),
                    .replacePages(
                        fromFileIndex: 1,
                        fromFilter: .include([.even]),
                        toFileIndex: 0,
                        toFilter: .include([.even])
                    )
                ],
                outputBaseFileNameWithoutExtension: nil
            )
        )
    }
}
