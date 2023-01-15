//
//  PDF Utils.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

extension PDFDocument {
    public var pageRange: Range<Int> {
        0 ..< pageCount
    }
    
    public var pageIndexes: [Int] {
        Array(pageRange)
    }
    
    public func pages() throws -> [PDFPage] {
        let getPages = pageRange.compactMap { page(at: $0) }
        guard pageCount == getPages.count else {
            throw PDFToolError.runtimeError(
                "Error while enumerating pages."
            )
        }
        return getPages
    }
    
    public func replaceAllPages<S: Collection>(
        with pages: S
    ) throws where S.Element == PDFPage {
        try removeAllPages()
        pages.enumerated().forEach { (pageIndex, page) in
            insert(page, at: pageIndex)
        }
        guard pageCount == pages.count else {
            throw PDFToolError.runtimeError(
                "Failed to replace all pages; page count differs."
            )
        }
    }
    
    public func removeAllPages() throws {
        pageRange.reversed().forEach {
            removePage(at: $0)
        }
        guard pageCount == 0 else {
            throw PDFToolError.runtimeError(
                "Failed to remove all pages."
            )
        }
    }
}
