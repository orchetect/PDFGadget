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
    
    func testSetFilenames() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        // check default filenames first
        XCTAssertEqual(tool.pdfs[0].filenameForExport, TestResource.pdf1page.name + "-processed")
        XCTAssertEqual(tool.pdfs[1].filenameForExport, TestResource.pdf2pages.name + "-processed")
        XCTAssertEqual(tool.pdfs[2].filenameForExport, TestResource.pdf5pages.name + "-processed")
        
        try tool.perform(operations: [
            .setFilenames(files: .all, filenames: ["Renamed1", "Renamed2", "Renamed3"])
        ])
        
        // check renamed files
        XCTAssertEqual(tool.pdfs[0].filenameForExport, "Renamed1")
        XCTAssertEqual(tool.pdfs[1].filenameForExport, "Renamed2")
        XCTAssertEqual(tool.pdfs[2].filenameForExport, "Renamed3")
    }
    
    func testRemoveFileAttributes() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        try tool.perform(operations: [
            .removeFileAttributes(files: .all)
        ])
        
        XCTAssertEqual(tool.pdfs.count, 1)
        try AssertPageIsEqual(
            tool.pdfs[0].doc.page(at: 0)!,
            testPDF1Page_withAttrAnno().page(at: 0)!,
            ignoreOpenState: true
        )
        XCTAssertEqual(tool.pdfs[0].doc.documentAttributes?.count ?? 0, 0)
    }
    
    func testSetFileAttribute() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        // set new value
        
        try tool.perform(operations: [
            .setFileAttribute(files: .all, .titleAttribute, value: "New Title")
        ])
        
        XCTAssertEqual(tool.pdfs[0].doc.documentAttributes?.count, 7)
        XCTAssertEqual(
            tool.pdfs[0].doc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String,
            "New Title"
        )
        
        // clear value
        
        try tool.perform(operations: [
            .setFileAttribute(files: .all, .titleAttribute, value: nil)
        ])
        
        XCTAssertEqual(tool.pdfs[0].doc.documentAttributes?.count, 6)
        XCTAssert(
            tool.pdfs[0].doc.documentAttributes?.keys.contains(PDFDocumentAttribute.titleAttribute) == false
        )
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
    
    func testExtractPlainText() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            try XCTUnwrap(PDFDocument(url: TestResource.loremIpsum.url()))
        ])
        
        let textPage1 = "TEXTPAGE1"
        
        try tool.perform(operations: [
            .extractPlainText(
                file: .first,
                pages: .include([.first(count: 1)]),
                to: .variable(named: textPage1),
                pageBreak: .none
            )
        ])
        
        let extractedPage1TextCase = try XCTUnwrap(tool.variables[textPage1])
        guard case let .string(extractedPage1Text) = extractedPage1TextCase
        else { XCTFail(); return }
        
        let expectedPage1Text = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ultrices
            vel mi vitae pharetra. Pellentesque venenatis massa et dui viverra
            efficitur. Aliquam mollis ex sit amet nibh tincidunt, nec posuere orci
            tempor. Nullam eleifend, sem sed ornare laoreet, justo dolor ultrices
            tellus, eu viverra odio risus et ante. Curabitur vel tempus est. Fusce in
            ante aliquam, iaculis risus eget, ultricies magna. Morbi molestie sem
            auctor tristique luctus. Vivamus nisi augue, elementum at nibh vel,
            volutpat vestibulum justo. Nulla eu libero dui. Nulla non pharetra magna.
            Aliquam ut finibus dui, sit amet consequat lectus. Donec massa turpis,
            faucibus nec nisl posuere, cursus vestibulum tellus. Mauris dignissim
            orci a rutrum tristique. Quisque fermentum metus ut bibendum accumsan.
            Proin hendrerit vulputate nisi. Pellentesque suscipit lectus quam, sit
            amet fermentum quam accumsan at. Sed ac justo nisl. Duis leo dolor,
            suscipit elementum ligula a, consequat lacinia magna. Pellentesque at
            accumsan nisi. Interdum et malesuada fames ac ante ipsum primis in
            faucibus. Mauris efficitur metus eget massa malesuada placerat.
            Sed sed magna consectetur, facilisis magna vitae, consequat quam. Fusce
            semper libero risus, quis sagittis arcu ornare a. Morbi varius lacus eget
            magna sodales, eu auctor tortor porttitor. Aenean gravida justo ipsum,
            efficitur tempus velit iaculis sit amet. Duis ut suscipit ipsum, non
            vestibulum urna. Etiam viverra sit amet sapien ut viverra. Ut suscipit
            feugiat risus a lacinia. In hac habitasse platea dictumst. Duis fringilla
            tellus sed luctus consequat. Nam placerat venenatis ligula pharetra
            laoreet. Donec quis purus non tortor blandit facilisis. Proin iaculis
            augue eu dignissim sagittis. Proin elementum dui iaculis diam blandit
            aliquam. Duis in nunc leo. Quisque mattis risus quis lacinia interdum.
            Nullam nec pulvinar massa.
            Sed molestie nisi ligula, id semper ante ullamcorper eget. Proin sed nisl
            aliquet, porta nisl ut, aliquet magna. Etiam volutpat congue est, eget
            pretium ligula feugiat quis. In consectetur tellus leo, nec malesuada
            mauris gravida mattis. Mauris viverra ultricies nibh at tempor. Donec
            blandit sem non rutrum mollis. Etiam metus erat, fermentum vel congue ut,
            bibendum rhoncus risus. Nulla tincidunt vehicula eleifend.
            Curabitur volutpat lorem et mauris efficitur, at dictum odio mollis. Nunc
            euismod euismod placerat. Morbi eleifend volutpat vehicula. Curabitur eu
            mauris vel purus commodo dignissim in a velit. Donec auctor tempus neque,
            vitae venenatis velit fringilla eu. Aliquam erat volutpat. Morbi iaculis,
            nisl vitae consectetur consectetur, tortor odio imperdiet nisi, quis
            suscipit libero urna non dui. Fusce tempor rhoncus commodo. Proin
            molestie porta nisi. Proin id felis ante. Nulla vulputate nunc nulla, sit
            amet consequat felis ornare non. Morbi tristique vitae nunc ut pretium.
            Pellentesque ac orci tincidunt, tempus nisi eget, volutpat sapien. Fusce
            """
        
        // TODO: This could be a flakey test if PDFKit changes how it extracts text from PDFs.
        // oddly enough, PDFKit has slightly different behaviors on different platforms (and has changed over time).
        // sometimes it pads extracted text with whitespace and/or trailing line-break, sometimes it doesn't.
        // for our tests we choose to ignore these differences when comparing.
        XCTAssertEqual(
            extractedPage1Text.trimmingCharacters(in: .whitespacesAndNewlines),
            expectedPage1Text
        )
    }
    
    func testRemoveProtections() throws {
        // note: PDF password is "1234"
        
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            try XCTUnwrap(PDFDocument(url: TestResource.permissions.url()))
        ])
        
        // check initial permission status
        XCTAssertTrue(tool.pdfs[0].doc.allowsContentAccessibility)
        XCTAssertFalse(tool.pdfs[0].doc.allowsCommenting)
        XCTAssertTrue(tool.pdfs[0].doc.allowsCopying)
        XCTAssertTrue(tool.pdfs[0].doc.allowsPrinting)
        XCTAssertFalse(tool.pdfs[0].doc.allowsDocumentAssembly)
        XCTAssertFalse(tool.pdfs[0].doc.allowsDocumentChanges)
        XCTAssertFalse(tool.pdfs[0].doc.allowsFormFieldEntry)
        // check initial encryption status
        XCTAssertTrue(tool.pdfs[0].doc.isEncrypted)
        XCTAssertFalse(tool.pdfs[0].doc.isLocked)
        // capture document atrributes
        let originalDocumentAttributes = tool.pdfs[0].doc.documentAttributes
        
        // remove protections
        let result = try tool.perform(operation: .removeProtections(files: .all))
        XCTAssertEqual(result, .changed)
        
        // check permission status
        XCTAssertTrue(tool.pdfs[0].doc.allowsContentAccessibility)
        XCTAssertTrue(tool.pdfs[0].doc.allowsCommenting)
        XCTAssertTrue(tool.pdfs[0].doc.allowsCopying)
        XCTAssertTrue(tool.pdfs[0].doc.allowsPrinting)
        XCTAssertTrue(tool.pdfs[0].doc.allowsDocumentAssembly)
        XCTAssertTrue(tool.pdfs[0].doc.allowsDocumentChanges)
        XCTAssertTrue(tool.pdfs[0].doc.allowsFormFieldEntry)
        // check encryption status
        XCTAssertFalse(tool.pdfs[0].doc.isEncrypted)
        XCTAssertFalse(tool.pdfs[0].doc.isLocked)
        // check document attributes are retained
        XCTAssertEqual(tool.pdfs[0].doc.documentAttributes?.count, originalDocumentAttributes?.count)
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
    func AssertDocumentsAreEqual(_ lhs: PDFDocument, _ rhs: PDFDocument, ignoreOpenState: Bool = false) throws {
        try AssertPagesAreEqual(lhs.pages(for: .all), rhs.pages(for: .all), ignoreOpenState: ignoreOpenState)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPagesAreEqual(_ lhs: [PDFPage], _ rhs: [PDFPage], ignoreOpenState: Bool = false) throws {
        XCTAssertEqual(lhs.count, rhs.count)
        
        for (lhsPage, rhsPage) in zip(lhs, rhs) {
            try AssertPageIsEqual(lhsPage, rhsPage, ignoreOpenState: ignoreOpenState)
        }
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func AssertPageIsEqual(
        _ lhs: PDFPage,
        _ rhs: PDFPage,
        ignoreOpenState: Bool = false,
        ignoreSurroundingTextWhitespace: Bool = true
    ) throws {
        // oddly enough, PDFKit has slightly different behaviors on different platforms (and has changed over time).
        // sometimes it pads extracted text with whitespace and/or trailing line-break, sometimes it doesn't.
        // for our tests we choose to ignore these differences when comparing.
        let lhsString = ignoreSurroundingTextWhitespace
            ? lhs.string?.trimmingCharacters(in: .whitespacesAndNewlines)
            : lhs.string
        let rhsString = ignoreSurroundingTextWhitespace
            ? rhs.string?.trimmingCharacters(in: .whitespacesAndNewlines)
            : rhs.string
        XCTAssertEqual(lhsString, rhsString)
        
        XCTAssertEqual(lhs.annotations.count, rhs.annotations.count)
        for (lhsAnno, rhsAnno) in zip(lhs.annotations, rhs.annotations) {
            try AssertAnnotationIsEqual(lhsAnno, rhsAnno, ignoreOpenState: ignoreOpenState)
        }
    }
    
    /// Checks page text. Convenience to identify a page for unit testing purposes.
    func Assert(page: PDFPage?, isTagged: String) throws {
        guard let page else { XCTFail("Page is nil.") ; return }
        XCTAssertEqual(page.string?.trimmed, isTagged)
    }
    
    /// Checks if two annotations have equal content.
    /// Not an exhaustive check but enough for unit testing.
    func AssertAnnotationIsEqual(
        _ lhs: PDFAnnotation,
        _ rhs: PDFAnnotation,
        ignoreOpenState: Bool
    ) throws {
        XCTAssertEqual(lhs.type, rhs.type)
        XCTAssertEqual(lhs.bounds, rhs.bounds)
        XCTAssertEqual(lhs.contents, rhs.contents)
        
        if ignoreOpenState {
            // it seems at some point PDFKit gained the behavior of removing the Open
            // annotation property during the course of loading/manipulating PDF documents
            // so it may be desirable to exempt the property from comparison.
            let lhsAKV = lhs.annotationKeyValues.filter { $0.key.base as? String != "/Open" }
            let rhsAKV = rhs.annotationKeyValues.filter { $0.key.base as? String != "/Open" }
            XCTAssertEqual(lhsAKV.count, rhsAKV.count)
        } else {
            XCTAssertEqual(lhs.annotationKeyValues.count, rhs.annotationKeyValues.count)
        }
    }
}

#endif
