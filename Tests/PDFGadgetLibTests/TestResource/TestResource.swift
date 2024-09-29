//
//  TestResource.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
import XCTest

// NOTE: DO NOT name any folders "Resources". Xcode will fail to build iOS targets.

// MARK: - Constants

/// Resources files on disk used for unit testing.
enum TestResource: CaseIterable {
    static let pdf1page = TestResource.File(
        name: "1Page", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf2pages = TestResource.File(
        name: "2Pages", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf5pages = TestResource.File(
        name: "5Pages", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf1page_withAttributes_withAnnotations = TestResource.File(
        name: "1Page-WithAttributes-WithAnnotations", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let loremIpsum = TestResource.File(
        name: "LoremIpsum", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let permissions = TestResource.File(
        name: "Permissions", ext: "pdf", subFolder: "PDF Files"
    )
}

// MARK: - Utilities

extension TestResource {
    struct File: Equatable, Hashable {
        let name: String
        let ext: String
        let subFolder: String?
        
        var fileName: String { name + "." + ext }
    }
}

extension TestResource.File {
    func url(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        // Bundle.module is synthesized when the package target has `resources: [...]`
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: subFolder
        )
        else {
            var msg = message()
            msg = msg.isEmpty ? "" : ": \(msg)"
            XCTFail(
                "Could not form URL, possibly could not find file.\(msg)",
                file: file,
                line: line
            )
            throw XCTSkip()
        }
        return url
    }
    
    func data(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let url = try url()
        guard let data = try? Data(contentsOf: url)
        else {
            var msg = message()
            msg = msg.isEmpty ? "" : ": \(msg)"
            XCTFail(
                "Could not read file at URL: \(url.absoluteString).",
                file: file,
                line: line
            )
            throw XCTSkip("Aborting test.")
        }
        return data
    }
}
