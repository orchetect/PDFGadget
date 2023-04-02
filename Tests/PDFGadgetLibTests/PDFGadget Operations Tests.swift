//
//  PDFGadget Operations Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import XCTest
@testable import PDFGadgetLib
import PDFKit
import OTCore

/// These are integration tests to test the actual operations,
/// not the specific syntax or underlying semantics.
final class PDFGadgetOperationsTests: XCTestCase {
    func testNewFile() throws {
        let tool = PDFGadget()
        
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
        let tool = PDFGadget()
        
        try tool.load(pdfs: [TestResource.pdf1page.url()])
        
        try tool.perform(operations: [
            .cloneFile(file: .first)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        try AssertFilesAreEqual(tool.pdfs[0], tool.pdfs[1])
        
        try Assert(page: tool.pdfs[0].doc.page(at: 0), isTagged: "1")
        try Assert(page: tool.pdfs[1].doc.page(at: 0), isTagged: "1")
    }
    
    func testFilterFiles() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        // all
        
        try tool.perform(operations: [
            .filterFiles(.all)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        // index range
        
        try tool.perform(operations: [
            .filterFiles(.indexRange(1...2))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF2Pages())
        try AssertDocumentIsEqual(tool.pdfs[1].doc, testPDF5Pages())
        
        // index
        
        try tool.perform(operations: [
            .filterFiles(.index(1))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF5Pages())
    }
    
    func testMergeFilesA() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .mergeFiles()
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 8)
        try AssertPagesAreEqual(
            tool.pdfs[0].doc.pages(for: .all),
            testPDF1Page().pages() + testPDF2Pages().pages() + testPDF5Pages().pages()
        )
    }
    
    func testMergeFilesB() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .mergeFiles(.second, appendingTo: .last)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 2)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        XCTAssertEqual(tool.pdfs[1].doc.pageCount, 7)
        try AssertPagesAreEqual(
            tool.pdfs[1].doc.pages(for: .all),
            testPDF5Pages().pages() + testPDF2Pages().pages()
        )
    }
    
    func testSetFilename() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        // just check default filename - not important for this test but we'll do it any way
        XCTAssertEqual(tool.pdfs[1].filenameForExport, TestResource.pdf2pages.name + "-processed")
        
        try tool.perform(operations: [
            .setFilename(file: .index(1), filename: "NewFileName")
        ])
        
        XCTAssertEqual(tool.pdfs[1].filenameForExport, "NewFileName")
    }
    
    func testFilterPages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .filterPages(file: .index(2), pages: .include([.oddNumbers]))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        try AssertDocumentIsEqual(tool.pdfs[1].doc, testPDF2Pages())
        try AssertPagesAreEqual(tool.pdfs[2].doc.pages(), testPDF5Pages().pages(at: [0, 2, 4]))
    }
    
    func testCopyPages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .copyPages(fromFile: .index(2),
                       fromPages: .include([.evenNumbers]),
                       toFile: .index(1),
                       toPageIndex: 1)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        let fileIdx1Pages = try tool.pdfs[1].doc.pages()
        XCTAssertEqual(fileIdx1Pages.count, 2 + 2)
        try Assert(page: fileIdx1Pages[0], isTagged: "1") // testPDF2Pages page 1
        try Assert(page: fileIdx1Pages[1], isTagged: "2") // testPDF5Pages page 2
        try Assert(page: fileIdx1Pages[2], isTagged: "4") // testPDF5Pages page 4
        try Assert(page: fileIdx1Pages[3], isTagged: "2") // testPDF2Pages page 2
        
        try AssertDocumentIsEqual(tool.pdfs[2].doc, testPDF5Pages())
    }
    
    func testMovePages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .movePages(fromFile: .index(2),
                       fromPages: .include([.evenNumbers]),
                       toFile: .index(1),
                       toPageIndex: 1)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        let fileIdx1Pages = try tool.pdfs[1].doc.pages()
        XCTAssertEqual(fileIdx1Pages.count, 2 + 2)
        try Assert(page: fileIdx1Pages[0], isTagged: "1") // testPDF2Pages page 1
        try Assert(page: fileIdx1Pages[1], isTagged: "2") // testPDF5Pages page 2
        try Assert(page: fileIdx1Pages[2], isTagged: "4") // testPDF5Pages page 4
        try Assert(page: fileIdx1Pages[3], isTagged: "2") // testPDF2Pages page 2
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        XCTAssertEqual(fileIdx2Pages.count, 5 - 2)
        try Assert(page: fileIdx2Pages[0], isTagged: "1")
        try Assert(page: fileIdx2Pages[1], isTagged: "3")
        try Assert(page: fileIdx2Pages[2], isTagged: "5")
    }
    
    /// Replace pages by copying.
    func testReplacePagesCopy() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .replacePages(fromFile: .second,
                          fromPages: .all,
                          toFile: .last,
                          toPages: .include([.range(indexes: 3 ... 4)]),
                          behavior: .copy)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        try AssertDocumentIsEqual(tool.pdfs[1].doc, testPDF2Pages())
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        XCTAssertEqual(fileIdx2Pages.count, 5)
        try Assert(page: fileIdx2Pages[0], isTagged: "1") // testPDF5Pages page 1
        try Assert(page: fileIdx2Pages[1], isTagged: "2") // testPDF5Pages page 2
        try Assert(page: fileIdx2Pages[2], isTagged: "3") // testPDF5Pages page 3
        try Assert(page: fileIdx2Pages[3], isTagged: "1") // testPDF2Pages page 1
        try Assert(page: fileIdx2Pages[4], isTagged: "2") // testPDF2Pages page 2
    }
    
    /// Replace pages by moving.
    func testReplacePagesMove() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .replacePages(fromFile: .second,
                          fromPages: .all,
                          toFile: .last,
                          toPages: .include([.range(indexes: 3 ... 4)]),
                          behavior: .move)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        try AssertDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        XCTAssertEqual(tool.pdfs[1].doc.pageCount, 0)
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        XCTAssertEqual(fileIdx2Pages.count, 5)
        try Assert(page: fileIdx2Pages[0], isTagged: "1") // testPDF5Pages page 1
        try Assert(page: fileIdx2Pages[1], isTagged: "2") // testPDF5Pages page 2
        try Assert(page: fileIdx2Pages[2], isTagged: "3") // testPDF5Pages page 3
        try Assert(page: fileIdx2Pages[3], isTagged: "1") // testPDF2Pages page 1
        try Assert(page: fileIdx2Pages[4], isTagged: "2") // testPDF2Pages page 2
    }
    
    /// Reverse page order of all pages of a file.
    func testReversePageOrderA() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .reversePageOrder(file: .first, pages: .all)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        
        let filePages = try tool.pdfs[0].doc.pages()
        XCTAssertEqual(filePages.count, 5)
        try Assert(page: filePages[0], isTagged: "5")
        try Assert(page: filePages[1], isTagged: "4")
        try Assert(page: filePages[2], isTagged: "3")
        try Assert(page: filePages[3], isTagged: "2")
        try Assert(page: filePages[4], isTagged: "1")
    }
    
    /// Reverse page order of some pages of a file.
    func testReversePageOrderB() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .reversePageOrder(file: .first, pages: .include([.range(indexes: 1 ... 3)]))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        
        let filePages = try tool.pdfs[0].doc.pages()
        XCTAssertEqual(filePages.count, 5)
        try Assert(page: filePages[0], isTagged: "1")
        try Assert(page: filePages[1], isTagged: "4")
        try Assert(page: filePages[2], isTagged: "3")
        try Assert(page: filePages[3], isTagged: "2")
        try Assert(page: filePages[4], isTagged: "5")
    }
    
    func testRotatePages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        // establish baseline
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 1)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 2)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 3)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 4)?.rotation, 0)
        
        // absolute rotation
        try tool.perform(operations: [
            .rotatePages(
                file: .first,
                pages: .include([.pages(indexes: [2])]),
                rotation: .init(angle: ._180degrees, process: .absolute)
            )
        ])
        
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 1)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 2)?.rotation, 180)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 3)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 4)?.rotation, 0)
        
        // relative rotation
        try tool.perform(operations: [
            .rotatePages(
                file: .first,
                pages: .include([.pages(indexes: [2])]),
                rotation: .init(angle: ._90degrees, process: .relative)
            )
        ])
        
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 1)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 2)?.rotation, 270)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 3)?.rotation, 0)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 4)?.rotation, 0)
    }
    
    func testSplitFile() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .splitFile(file: .first, discardUnused: false, .every(pageCount: 2))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 3)
        
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 2)
        try Assert(page: tool.pdfs[0].doc.page(at: 0), isTagged: "1")
        try Assert(page: tool.pdfs[0].doc.page(at: 1), isTagged: "2")
        
        XCTAssertEqual(tool.pdfs[1].doc.pageCount, 2)
        try Assert(page: tool.pdfs[1].doc.page(at: 0), isTagged: "3")
        try Assert(page: tool.pdfs[1].doc.page(at: 1), isTagged: "4")
        
        XCTAssertEqual(tool.pdfs[2].doc.pageCount, 1)
        try Assert(page: tool.pdfs[2].doc.page(at: 0), isTagged: "5")
    }
    
    func testFilterAnnotations() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        // all
        
        try tool.perform(operations: [
            .filterAnnotations(file: .first, pages: .all, annotations: .all)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 1)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.annotations.count, 8)
        
        // specific subtypes
        
        try tool.perform(operations: [
            .filterAnnotations(file: .first, pages: .all, annotations: .exclude([.circle, .square]))
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 1)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.annotations.count, 6)
        
        
        // none
        
        try tool.perform(operations: [
            .filterAnnotations(file: .first, pages: .all, annotations: .none)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        
        XCTAssertEqual(tool.pdfs[0].doc.pageCount, 1)
        XCTAssertEqual(tool.pdfs[0].doc.page(at: 0)?.annotations.count, 0)
    }
}

// MARK: - Utils

extension PDFGadgetOperationsTests {
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
    func AssertFileIsEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try AssertDocumentIsEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that the files are generally the same.
    /// Not an exhaustive check but enough for unit testing.
    func AssertDocumentIsEqual(_ lhs: PDFDocument, _ rhs: PDFDocument) throws {
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
        
        try AssertDocumentsAreEqual(lhs, rhs)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertFilesAreEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try AssertDocumentsAreEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertDocumentsAreEqual(_ lhs: PDFDocument, _ rhs: PDFDocument) throws {
        try AssertPagesAreEqual(lhs.pages(for: .all), rhs.pages(for: .all))
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPagesAreEqual(_ lhs: [PDFPage], _ rhs: [PDFPage]) throws {
        XCTAssertEqual(lhs.count, rhs.count)
        
        for (lhsPage, rhsPage) in zip(lhs, rhs) {
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

#endif
