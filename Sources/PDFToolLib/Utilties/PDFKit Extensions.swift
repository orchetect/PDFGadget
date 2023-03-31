//
//  PDFKit Extensions.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

extension PDFDocument {
    // MARK: - Page Indexes
    
    public var pageRange: Range<Int> {
        0 ..< pageCount
    }
    
    public func pageIndexes(at range: Range<Int>? = nil) -> [Int] {
        Array(range ?? pageRange)
    }
    
    public func pageIndexes(
        filter: PDFPagesFilter
    ) throws -> IndexesDiff {
        filter.filtering(pageIndexes())
    }
    
    // MARK: - Page Access
    
    public func pages(at range: Range<Int>) throws -> [PDFPage] {
        try pages(at: pageIndexes(at: range))
    }
    
    public func pages(at indexes: [Int]? = nil) throws -> [PDFPage] {
        let i = indexes ?? pageIndexes()
        let getPages = i.compactMap { page(at: $0) }
        guard i.count == getPages.count else {
            throw PDFToolError.runtimeError(
                "Error while enumerating pages."
            )
        }
        return getPages
    }
    
    public func pages(for filter: PDFPagesFilter) throws -> [PDFPage] {
        try pages(at: pageIndexes(filter: filter).included)
    }
    
    // MARK: - Page Operations
    
    public func append(page: PDFPage) {
        self.insert(page, at: pageCount)
    }
    
    public func append(pages: [PDFPage]) {
        for page in pages {
            append(page: page)
        }
    }
    
    public func insert(_ pages: [PDFPage], at index: Int) throws {
        guard pageRange.contains(index) || pageCount == index else {
            throw PDFToolError.runtimeError(
                "Page index is out of range."
            )
        }
        
        for page in pages.reversed() {
            insert(page, at: index)
        }
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
    
    public func removePages(at indexes: [Int]) throws {
        guard indexes.allSatisfy(pageRange.contains(_:)) else {
            throw PDFToolError.runtimeError(
                "One or more page indexes were not found while attempting to remove pages."
            )
        }
        
        let originalPageCount = pageCount
        
        indexes.sorted().reversed().forEach {
            removePage(at: $0)
        }
        
        let postPageCount = pageCount
        
        guard originalPageCount - postPageCount == indexes.count else {
            throw PDFToolError.runtimeError(
                "Failed to remove pages. Resulting page count is not as expected."
            )
        }
    }
    
    public func exchangePage(at index: Int, withPage other: PDFPage) throws {
        guard pageIndexes().contains(index) else {
            throw PDFToolError.runtimeError(
                "Failed to replace page. Index is out of bounds: \(index)."
            )
        }
        removePage(at: index)
        insert(other, at: index)
    }
    
    // MARK: - File Info
    
    public var filenameWithoutExtension: String? {
        self.documentURL?.deletingPathExtension().lastPathComponent
    }
}

extension PDFAnnotation {
    func matches(subType: PDFAnnotationSubtype) -> Bool {
        guard let annoType = type else { return false }
        
        // includes a workaround for an inexplicable issue where
        // PDFAnnotationSubtype.rawValue adds a forward-slash character
        
        return subType.rawValue == annoType ||
            subType.rawValue == "/" + annoType
    }
    
    func type(containedIn subTypes: [PDFAnnotationSubtype]) -> Bool {
        subTypes.contains { matches(subType: $0) }
    }
}
