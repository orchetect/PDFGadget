//
//  PDFGadget Operations Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

@testable import PDFGadget
internal import OTCore
import PDFKit
import Testing
import TestingExtensions

/// These are integration tests to test the actual operations,
/// not the specific syntax or underlying semantics.
@Suite struct PDFGadgetOperationsTests {
    @Test func newFile() throws {
        let tool = PDFGadget()
        
        try tool.perform(operations: [
            .newFile
        ])
        
        #expect(tool.pdfs.count == 1)
        #expect(tool.pdfs[0].doc.pageCount == 0)
        
        try tool.perform(operations: [
            .newFile
        ])
        
        #expect(tool.pdfs.count == 2)
        #expect(tool.pdfs[1].doc.pageCount == 0)
    }
    
    @Test func cloneFile() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [TestResource.pdf1page.url()])
        
        try tool.perform(operations: [
            .cloneFile(file: .first)
        ])
        
        #expect(tool.pdfs.count == 2)
        try expectFilesAreEqual(tool.pdfs[0], tool.pdfs[1])
        
        try expect(page: tool.pdfs[0].doc.page(at: 0), isTagged: "1")
        try expect(page: tool.pdfs[1].doc.page(at: 0), isTagged: "1")
    }
    
    @Test func filterFiles() throws {
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
        
        #expect(tool.pdfs.count == 3)
        
        // index range
        
        try tool.perform(operations: [
            .filterFiles(.indexRange(1 ... 2))
        ])
        
        #expect(tool.pdfs.count == 2)
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF2Pages())
        try expectDocumentIsEqual(tool.pdfs[1].doc, testPDF5Pages())
        
        // index
        
        try tool.perform(operations: [
            .filterFiles(.index(1))
        ])
        
        #expect(tool.pdfs.count == 1)
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF5Pages())
    }
    
    @Test func mergeFilesA() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .mergeFiles()
        ])
        
        #expect(tool.pdfs.count == 1)
        #expect(tool.pdfs[0].doc.pageCount == 8)
        try expectPagesAreEqual(
            tool.pdfs[0].doc.pages(for: .all),
            testPDF1Page().pages() + testPDF2Pages().pages() + testPDF5Pages().pages()
        )
    }
    
    @Test func mergeFilesB() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .mergeFiles(.second, appendingTo: .last)
        ])
        
        #expect(tool.pdfs.count == 2)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        #expect(tool.pdfs[1].doc.pageCount == 7)
        try expectPagesAreEqual(
            tool.pdfs[1].doc.pages(for: .all),
            testPDF5Pages().pages() + testPDF2Pages().pages()
        )
    }
    
    @Test func splitFile() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .splitFile(file: .first, discardUnused: false, .every(pageCount: 2))
        ])
        
        #expect(tool.pdfs.count == 3)
        
        #expect(tool.pdfs[0].doc.pageCount == 2)
        try expect(page: tool.pdfs[0].doc.page(at: 0), isTagged: "1")
        try expect(page: tool.pdfs[0].doc.page(at: 1), isTagged: "2")
        
        #expect(tool.pdfs[1].doc.pageCount == 2)
        try expect(page: tool.pdfs[1].doc.page(at: 0), isTagged: "3")
        try expect(page: tool.pdfs[1].doc.page(at: 1), isTagged: "4")
        
        #expect(tool.pdfs[2].doc.pageCount == 1)
        try expect(page: tool.pdfs[2].doc.page(at: 0), isTagged: "5")
    }
    
    @Test func setFilename() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        // just check default filename - not important for this test but we'll do it any way
        #expect(tool.pdfs[1].filenameForExport(withExtension: false) == TestResource.pdf2pages.name + "-processed")
        
        try tool.perform(operations: [
            .setFilename(file: .index(1), filename: "NewFileName")
        ])
        
        #expect(tool.pdfs[1].filenameForExport(withExtension: false) == "NewFileName")
    }
    
    @Test func setFilenames() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        // check default filenames first
        #expect(tool.pdfs[0].filenameForExport(withExtension: false) == TestResource.pdf1page.name + "-processed")
        #expect(tool.pdfs[1].filenameForExport(withExtension: false) == TestResource.pdf2pages.name + "-processed")
        #expect(tool.pdfs[2].filenameForExport(withExtension: false) == TestResource.pdf5pages.name + "-processed")
        
        try tool.perform(operations: [
            .setFilenames(files: .all, filenames: ["Renamed1", "Renamed2", "Renamed3"])
        ])
        
        // check renamed files
        #expect(tool.pdfs[0].filenameForExport(withExtension: false) == "Renamed1")
        #expect(tool.pdfs[1].filenameForExport(withExtension: false) == "Renamed2")
        #expect(tool.pdfs[2].filenameForExport(withExtension: false) == "Renamed3")
    }
    
    @Test func removeFileAttributes() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        try tool.perform(operations: [
            .removeFileAttributes(files: .all)
        ])
        
        #expect(tool.pdfs.count == 1)
        try expectPageIsEqual(
            tool.pdfs[0].doc.page(at: 0)!,
            testPDF1Page_withAttrAnno().page(at: 0)!,
            ignoreOpenState: true
        )
        #expect(tool.pdfs[0].doc.documentAttributes?.count ?? 0 == 0)
    }
    
    @Test func setFileAttribute() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        // set new value
        
        try tool.perform(operations: [
            .setFileAttribute(files: .all, .titleAttribute, value: "New Title")
        ])
        
        #expect(tool.pdfs[0].doc.documentAttributes?.count == 7)
        #expect(
            tool.pdfs[0].doc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ==
            "New Title"
        )
        
        // clear value
        
        try tool.perform(operations: [
            .setFileAttribute(files: .all, .titleAttribute, value: nil)
        ])
        
        #expect(tool.pdfs[0].doc.documentAttributes?.count == 6)
        #expect(
            tool.pdfs[0].doc.documentAttributes?.keys
                .contains(PDFDocumentAttribute.titleAttribute) == false
        )
    }
    
    @Test func filterPages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .filterPages(file: .index(2), pages: .include([.oddNumbers]))
        ])
        
        #expect(tool.pdfs.count == 3)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        try expectDocumentIsEqual(tool.pdfs[1].doc, testPDF2Pages())
        try expectPagesAreEqual(tool.pdfs[2].doc.pages(), testPDF5Pages().pages(at: [0, 2, 4]))
    }
    
    @Test func copyPages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .copyPages(
                fromFile: .index(2),
                fromPages: .include([.evenNumbers]),
                toFile: .index(1),
                toPageIndex: 1
            )
        ])
        
        #expect(tool.pdfs.count == 3)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        let fileIdx1Pages = try tool.pdfs[1].doc.pages()
        #expect(fileIdx1Pages.count == 2 + 2)
        try expect(page: fileIdx1Pages[0], isTagged: "1") // testPDF2Pages page 1
        try expect(page: fileIdx1Pages[1], isTagged: "2") // testPDF5Pages page 2
        try expect(page: fileIdx1Pages[2], isTagged: "4") // testPDF5Pages page 4
        try expect(page: fileIdx1Pages[3], isTagged: "2") // testPDF2Pages page 2
        
        try expectDocumentIsEqual(tool.pdfs[2].doc, testPDF5Pages())
    }
    
    @Test func movePages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .movePages(
                fromFile: .index(2),
                fromPages: .include([.evenNumbers]),
                toFile: .index(1),
                toPageIndex: 1
            )
        ])
        
        #expect(tool.pdfs.count == 3)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        let fileIdx1Pages = try tool.pdfs[1].doc.pages()
        #expect(fileIdx1Pages.count == 2 + 2)
        try expect(page: fileIdx1Pages[0], isTagged: "1") // testPDF2Pages page 1
        try expect(page: fileIdx1Pages[1], isTagged: "2") // testPDF5Pages page 2
        try expect(page: fileIdx1Pages[2], isTagged: "4") // testPDF5Pages page 4
        try expect(page: fileIdx1Pages[3], isTagged: "2") // testPDF2Pages page 2
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        #expect(fileIdx2Pages.count == 5 - 2)
        try expect(page: fileIdx2Pages[0], isTagged: "1")
        try expect(page: fileIdx2Pages[1], isTagged: "3")
        try expect(page: fileIdx2Pages[2], isTagged: "5")
    }
    
    /// Replace pages by copying.
    @Test func replacePagesCopy() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .replacePages(
                fromFile: .second,
                fromPages: .all,
                toFile: .last,
                toPages: .include([.range(indexes: 3 ... 4)]),
                behavior: .copy
            )
        ])
        
        #expect(tool.pdfs.count == 3)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        try expectDocumentIsEqual(tool.pdfs[1].doc, testPDF2Pages())
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        #expect(fileIdx2Pages.count == 5)
        try expect(page: fileIdx2Pages[0], isTagged: "1") // testPDF5Pages page 1
        try expect(page: fileIdx2Pages[1], isTagged: "2") // testPDF5Pages page 2
        try expect(page: fileIdx2Pages[2], isTagged: "3") // testPDF5Pages page 3
        try expect(page: fileIdx2Pages[3], isTagged: "1") // testPDF2Pages page 1
        try expect(page: fileIdx2Pages[4], isTagged: "2") // testPDF2Pages page 2
    }
    
    /// Replace pages by moving.
    @Test func replacePagesMove() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page(),
            testPDF2Pages(),
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .replacePages(
                fromFile: .second,
                fromPages: .all,
                toFile: .last,
                toPages: .include([.range(indexes: 3 ... 4)]),
                behavior: .move
            )
        ])
        
        #expect(tool.pdfs.count == 3)
        
        try expectDocumentIsEqual(tool.pdfs[0].doc, testPDF1Page())
        
        #expect(tool.pdfs[1].doc.pageCount == 0)
        
        let fileIdx2Pages = try tool.pdfs[2].doc.pages()
        #expect(fileIdx2Pages.count == 5)
        try expect(page: fileIdx2Pages[0], isTagged: "1") // testPDF5Pages page 1
        try expect(page: fileIdx2Pages[1], isTagged: "2") // testPDF5Pages page 2
        try expect(page: fileIdx2Pages[2], isTagged: "3") // testPDF5Pages page 3
        try expect(page: fileIdx2Pages[3], isTagged: "1") // testPDF2Pages page 1
        try expect(page: fileIdx2Pages[4], isTagged: "2") // testPDF2Pages page 2
    }
    
    /// Reverse page order of all pages of a file.
    @Test func reversePageOrderA() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .reversePageOrder(file: .first, pages: .all)
        ])
        
        #expect(tool.pdfs.count == 1)
        
        let filePages = try tool.pdfs[0].doc.pages()
        #expect(filePages.count == 5)
        try expect(page: filePages[0], isTagged: "5")
        try expect(page: filePages[1], isTagged: "4")
        try expect(page: filePages[2], isTagged: "3")
        try expect(page: filePages[3], isTagged: "2")
        try expect(page: filePages[4], isTagged: "1")
    }
    
    /// Reverse page order of some pages of a file.
    @Test func reversePageOrderB() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        try tool.perform(operations: [
            .reversePageOrder(file: .first, pages: .include([.range(indexes: 1 ... 3)]))
        ])
        
        #expect(tool.pdfs.count == 1)
        
        let filePages = try tool.pdfs[0].doc.pages()
        #expect(filePages.count == 5)
        try expect(page: filePages[0], isTagged: "1")
        try expect(page: filePages[1], isTagged: "4")
        try expect(page: filePages[2], isTagged: "3")
        try expect(page: filePages[3], isTagged: "2")
        try expect(page: filePages[4], isTagged: "5")
    }
    
    @Test func rotatePages() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF5Pages()
        ])
        
        // establish baseline
        #expect(tool.pdfs[0].doc.page(at: 0)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 1)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 2)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 3)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 4)?.rotation == 0)
        
        // absolute rotation
        try tool.perform(operations: [
            .rotatePages(
                files: .first,
                pages: .include([.pages(indexes: [2])]),
                rotation: .init(angle: ._180degrees, apply: .absolute)
            )
        ])
        
        #expect(tool.pdfs[0].doc.page(at: 0)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 1)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 2)?.rotation == 180)
        #expect(tool.pdfs[0].doc.page(at: 3)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 4)?.rotation == 0)
        
        // relative rotation
        try tool.perform(operations: [
            .rotatePages(
                files: .first,
                pages: .include([.pages(indexes: [2])]),
                rotation: .init(angle: ._90degrees, apply: .relative)
            )
        ])
        
        #expect(tool.pdfs[0].doc.page(at: 0)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 1)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 2)?.rotation == 270)
        #expect(tool.pdfs[0].doc.page(at: 3)?.rotation == 0)
        #expect(tool.pdfs[0].doc.page(at: 4)?.rotation == 0)
    }
    
    // TODO: add unit test for 'crop' operation
    
    @Test func filterAnnotations() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        // initial conditions
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 8)
        
        // all
        
        try tool.perform(operations: [
            .filterAnnotations(files: .first, pages: .all, annotations: .all)
        ])
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.pageCount == 1)
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 8)
        
        // specific subtypes
        
        try tool.perform(operations: [
            .filterAnnotations(files: .first, pages: .all, annotations: .exclude([.circle, .square]))
        ])
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.pageCount == 1)
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 6)
        
        // none
        
        try tool.perform(operations: [
            .filterAnnotations(files: .first, pages: .all, annotations: .none)
        ])
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.pageCount == 1)
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 0)
    }
    
    @available(watchOS, unavailable)
    @Test func burnInAnnotations() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            testPDF1Page_withAttrAnno()
        ])
        
        // initial conditions
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 8)
        
        // set option
        
        try tool.perform(operations: [
            .burnInAnnotations(files: .all) // only takes effect on file write to disk
        ])
        
        try #require(tool.pdfs.count == 1)
        
        #expect(tool.pdfs[0].doc.pageCount == 1)
        #expect(tool.pdfs[0].doc.page(at: 0)?.annotations.count == 8)
        
        // write file and read it back
        // (must write to disk, as `dataRepresentation(options:)` does not take write options)
        
        let tempDir = FileManager.default.temporaryDirectoryCompat
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: false)
        // defer cleanup
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        try tool.savePDFs(outputDir: tempDir)
        let filename = tool.pdfs[0].filenameForExport(withExtension: true)
        let savedPDF = tempDir.appendingPathComponent(filename)
        let newDoc = try #require(PDFDocument(url: savedPDF))
        
        #expect(newDoc.page(at: 0)?.annotations.isEmpty == true)
    }
    
    @Test func extractPlainText() throws {
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            try #require(PDFDocument(url: TestResource.loremIpsum.url()))
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
        
        let extractedPage1TextCase = try #require(tool.variables[textPage1])
        guard case let .string(extractedPage1Text) = extractedPage1TextCase
        else { #fail(); return }
        
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
        // oddly enough, PDFKit has slightly different behaviors on different platforms (and has
        // changed over time).
        // sometimes it pads extracted text with whitespace and/or trailing line-break, sometimes it
        // doesn't.
        // for our tests we choose to ignore these differences when comparing.
        #expect(
            extractedPage1Text.trimmingCharacters(in: .whitespacesAndNewlines) ==
            expectedPage1Text
        )
    }
    
    @Test func removeProtections() throws {
        // note: PDF password is "1234"
        
        let tool = PDFGadget()
        
        try tool.load(pdfs: [
            try #require(PDFDocument(url: TestResource.permissions.url()))
        ])
        
        // check initial permission status
        #expect(tool.pdfs[0].doc.allowsContentAccessibility)
        #expect(!tool.pdfs[0].doc.allowsCommenting)
        #expect(tool.pdfs[0].doc.allowsCopying)
        #expect(tool.pdfs[0].doc.allowsPrinting)
        #expect(!tool.pdfs[0].doc.allowsDocumentAssembly)
        #expect(!tool.pdfs[0].doc.allowsDocumentChanges)
        #expect(!tool.pdfs[0].doc.allowsFormFieldEntry)
        // check initial encryption status
        #expect(tool.pdfs[0].doc.isEncrypted)
        #expect(!tool.pdfs[0].doc.isLocked)
        // capture document atrributes
        let originalDocumentAttributes = tool.pdfs[0].doc.documentAttributes
        
        // remove protections
        let result = try tool.perform(operation: .removeProtections(files: .all))
        #expect(result == .changed)
        
        // check permission status
        #expect(tool.pdfs[0].doc.allowsContentAccessibility)
        #expect(tool.pdfs[0].doc.allowsCommenting)
        #expect(tool.pdfs[0].doc.allowsCopying)
        #expect(tool.pdfs[0].doc.allowsPrinting)
        #expect(tool.pdfs[0].doc.allowsDocumentAssembly)
        #expect(tool.pdfs[0].doc.allowsDocumentChanges)
        #expect(tool.pdfs[0].doc.allowsFormFieldEntry)
        // check encryption status
        #expect(!tool.pdfs[0].doc.isEncrypted)
        #expect(!tool.pdfs[0].doc.isLocked)
        // check document attributes are retained
        #expect(
            tool.pdfs[0].doc.documentAttributes?.count ==
            originalDocumentAttributes?.count
        )
    }
}

// MARK: - Utils

extension PDFGadgetOperationsTests {
    // MARK: Test Resource Conveniences
    
    func testPDF1Page() throws -> PDFDocument {
        try #require(PDFDocument(url: TestResource.pdf1page.url()))
    }
    
    func testPDF2Pages() throws -> PDFDocument {
        try #require(PDFDocument(url: TestResource.pdf2pages.url()))
    }
    
    func testPDF5Pages() throws -> PDFDocument {
        try #require(PDFDocument(url: TestResource.pdf5pages.url()))
    }
    
    func testPDF1Page_withAttrAnno() throws -> PDFDocument {
        try #require(PDFDocument(url: TestResource.pdf1page_withAttributes_withAnnotations.url()))
    }
    
    // MARK: Expectations
    
    /// Checks that the files are generally the same.
    /// Not an exhaustive check but enough for unit testing.
    func expectFileIsEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try expectDocumentIsEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that the files are generally the same.
    /// Not an exhaustive check but enough for unit testing.
    func expectDocumentIsEqual(_ lhs: PDFDocument, _ rhs: PDFDocument) throws {
        if let lhsAttribs = lhs.documentAttributes {
            guard let rhsAttribs = rhs.documentAttributes else {
                #fail("Attributes are not equal."); return
            }
            // both docs have attributes, so we can compare them
            
            #expect(lhsAttribs.count == rhsAttribs.count)
            
            func compare(_ attr: PDFDocumentAttribute) throws {
                #expect(
                    lhsAttribs[attr] as? String ==
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
        
        try expectDocumentsAreEqual(lhs, rhs)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func expectFilesAreEqual(_ lhs: PDFFile, _ rhs: PDFFile) throws {
        try expectDocumentsAreEqual(lhs.doc, rhs.doc)
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func expectDocumentsAreEqual(
        _ lhs: PDFDocument,
        _ rhs: PDFDocument,
        ignoreOpenState: Bool = false
    ) throws {
        try expectPagesAreEqual(
            lhs.pages(for: .all),
            rhs.pages(for: .all),
            ignoreOpenState: ignoreOpenState
        )
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func expectPagesAreEqual(
        _ lhs: [PDFPage],
        _ rhs: [PDFPage],
        ignoreOpenState: Bool = false
    ) throws {
        #expect(lhs.count == rhs.count)
        
        for (lhsPage, rhsPage) in zip(lhs, rhs) {
            try expectPageIsEqual(lhsPage, rhsPage, ignoreOpenState: ignoreOpenState)
        }
    }
    
    /// Checks that pages are equal between two PDF files, by checking page text and annotations.
    /// Not an exhaustive check but enough for unit testing.
    func expectPageIsEqual(
        _ lhs: PDFPage,
        _ rhs: PDFPage,
        ignoreOpenState: Bool = false,
        ignoreSurroundingTextWhitespace: Bool = true
    ) throws {
        // oddly enough, PDFKit has slightly different behaviors on different platforms (and has
        // changed over time).
        // sometimes it pads extracted text with whitespace and/or trailing line-break, sometimes it
        // doesn't.
        // for our tests we choose to ignore these differences when comparing.
        let lhsString = ignoreSurroundingTextWhitespace
            ? lhs.string?.trimmingCharacters(in: .whitespacesAndNewlines)
            : lhs.string
        let rhsString = ignoreSurroundingTextWhitespace
            ? rhs.string?.trimmingCharacters(in: .whitespacesAndNewlines)
            : rhs.string
        #expect(lhsString == rhsString)
        
        #expect(lhs.annotations.count == rhs.annotations.count)
        for (lhsAnno, rhsAnno) in zip(lhs.annotations, rhs.annotations) {
            try expectAnnotationIsEqual(lhsAnno, rhsAnno, ignoreOpenState: ignoreOpenState)
        }
    }
    
    /// Checks page text. Convenience to identify a page for unit testing purposes.
    func expect(page: PDFPage?, isTagged: String) throws {
        guard let page else { #fail("Page is nil."); return }
        #expect(page.string?.trimmed == isTagged)
    }
    
    /// Checks if two annotations have equal content.
    /// Not an exhaustive check but enough for unit testing.
    func expectAnnotationIsEqual(
        _ lhs: PDFAnnotation,
        _ rhs: PDFAnnotation,
        ignoreOpenState: Bool
    ) throws {
        #expect(lhs.type == rhs.type)
        #expect(lhs.bounds == rhs.bounds)
        #expect(lhs.contents == rhs.contents)
        
        if ignoreOpenState {
            // it seems at some point PDFKit gained the behavior of removing the Open
            // annotation property during the course of loading/manipulating PDF documents
            // so it may be desirable to exempt the property from comparison.
            let lhsAKV = lhs.annotationKeyValues.filter { $0.key.base as? String != "/Open" }
            let rhsAKV = rhs.annotationKeyValues.filter { $0.key.base as? String != "/Open" }
            #expect(lhsAKV.count == rhsAKV.count)
        } else {
            #expect(lhs.annotationKeyValues.count == rhs.annotationKeyValues.count)
        }
    }
}

#endif
