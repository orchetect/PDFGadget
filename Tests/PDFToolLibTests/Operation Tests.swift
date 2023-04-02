//
//  Operation Tests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib
import PDFKit

/// These are integration tests to test the actual operations,
/// not the specific syntax or underlying semantics.
final class OperationTests: XCTestCase {
    func testNewFile() throws {
        let tool = PDFTool()
        
        try tool.perform(operations: [
            .newFile
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 0)
        
        try tool.perform(operations: [
            .newFile
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        XCTAssertEqual(tool.pdfs[1].doc.pageCount, 0)
    }
    
    func testCloneFile() throws {
        let tool = PDFTool()
        
        try tool.load(pdfs: [TestResource.pdf1page.url()])
        
        try tool.perform(operations: [
            .cloneFile(file: .first)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        try AssertPageContentsAreEqual(tool.pdfs[0], tool.pdfs[1])
        
        try Assert(page: tool.pdfs[0].doc.page(at: 0), isTagged: "1")
        try Assert(page: tool.pdfs[1].doc.page(at: 0), isTagged: "1")
    }
    
    func testFilterFiles() throws {
        let tool = PDFTool()
        
        let pdf1page = try testPDF1Page()
        let pdf2pages = try testPDF2Pages()
        let pdf5pages = try testPDF5Pages()
        
        try tool.load(pdfs: [
            pdf1page,
            pdf2pages,
            pdf5pages
        ])
        
        try tool.perform(operations: [
            .filterFiles(.indexRange(1...2))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        try AssertPDFIsEqual(tool.pdfs[0].doc, pdf2pages)
        try AssertPDFIsEqual(tool.pdfs[1].doc, pdf5pages)
    }
    
    func testMergeFiles() throws {
#warning("> write unit test")
    }
    
    func testFilterPages() throws {
#warning("> write unit test")
    }
    
    func testSetFilename() throws {
#warning("> write unit test")
    }
    
    func testCopyPages() throws {
#warning("> write unit test")
    }
    
    func testMovePages() throws {
#warning("> write unit test")
    }
    
    func testReversePageOrder() throws {
#warning("> write unit test")
    }
    
    func testReplacePages() throws {
#warning("> write unit test")
    }
    
    func testRotatePages() throws {
#warning("> write unit test")
    }
    
    func testSplitFile() throws {
#warning("> write unit test")
    }
    
    func testFilterAnnotations() throws {
#warning("> write unit test")
    }
}

// MARK: - Utils

extension OperationTests {
    // MARK: Test Resource Conveniences
    
    func testPDF1Page() throws -> PDFDocument {
        try XCTUnwrap(PDFDocument(url: TestResource.pdf1page.url()))
    }
    
    func testPDF2Pages() throws -> PDFDocument {
        try XCTUnwrap(PDFDocument(url: TestResource.pdf2pages.url()))
    }
    
    func testPDF5Pages() throws -> PDFDocument {
        try XCTUnwrap(PDFDocument(url: TestResource.pdf5pages.url()))
    }
    
    func testPDF1Page_withAttrAnno() throws -> PDFDocument {
        try XCTUnwrap(PDFDocument(url: TestResource.pdf1page_withAttributes_withAnnotations.url()))
    }
    
    // MARK: Assertions
    
    /// Checks that the files are generally the same.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPDFIsEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try AssertPDFIsEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that the files are generally the same.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPDFIsEqual(_ lhs: PDFDocument, _ rhs: PDFDocument) throws {
        if let lhsAttribs = lhs.documentAttributes {
            guard let rhsAttribs = rhs.documentAttributes else {
                XCTFail("Attributes are not equal.") ; return
            }
            // both docs have attributes, so we can compare them
            
            XCTAssertEqual(lhsAttribs.count, rhsAttribs.count)
            
            func compare(_ attr: PDFDocumentAttribute) throws {
                XCTAssertEqual(
                    lhsAttribs[attr] as? String,
                    rhsAttribs[attr] as? String
                )
            }
            
            try compare(.authorAttribute)
            try compare(.creationDateAttribute)
            try compare(.creatorAttribute)
            try compare(.keywordsAttribute)
            try compare(.modificationDateAttribute)
            try compare(.producerAttribute)
            try compare(.subjectAttribute)
            try compare(.titleAttribute)
        }
        
        try AssertPageContentsAreEqual(lhs, rhs)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPageContentsAreEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try AssertPageContentsAreEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPageContentsAreEqual(_ lhs: PDFDocument, _ rhs: PDFDocument) throws {
        XCTAssertEqual(lhs.pageCount, rhs.pageCount)
        
        for (lhsPage, rhsPage) in try zip(lhs.pages(for: .all), rhs.pages(for: .all)) {
            XCTAssertEqual(lhsPage.string, rhsPage.string)
            
            XCTAssertEqual(lhsPage.annotations.count, rhsPage.annotations.count)
            XCTAssertEqual(lhsPage.annotations, rhsPage.annotations) // TODO: not sure if this works as expected?
        }
    }
    
    /// Checks page text. Convenience to identify a page for unit testing purposes.
    func Assert(page: PDFPage?, isTagged: String) throws {
        guard let page else { XCTFail("Page is nil.") ; return }
        XCTAssertEqual(page.string?.trimmed, isTagged)
    }
}
