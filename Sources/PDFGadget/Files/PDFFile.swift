//
//  PDFFile.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// Internal wrapper for `PDFDocument` to contain metadata for processing and exporting.
class PDFFile {
    var doc: PDFDocument
    var writeOptions: [PDFDocumentWriteOption: Any]
    private var customExportFilename: String?
    
    init(
        doc: PDFDocument,
        customExportFilename: String? = nil,
        writeOptions: [PDFDocumentWriteOption: Any] = [:]
    ) {
        self.doc = doc
        self.customExportFilename = customExportFilename
        self.writeOptions = writeOptions
    }
    
    /// Initialize with a new empty `PDFDocument`.
    init() {
        doc = PDFDocument()
        self.customExportFilename = nil
        writeOptions = [:]
    }
}

extension PDFFile: Equatable {
    static func == (lhs: PDFFile, rhs: PDFFile) -> Bool {
        lhs.doc == rhs.doc
    }
}

extension PDFFile: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(doc)
    }
}

extension PDFFile: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        PDFFile(
            doc: doc.copy() as! PDFDocument,
            customExportFilename: customExportFilename,
            writeOptions: writeOptions
        )
    }
}

extension PDFFile: CustomStringConvertible {
    var description: String {
        "PDFFile(\(filenameForExport(withExtension: true)))"
    }
}

extension PDFFile {
    /// Return the consolidated filename for export.
    func filenameForExport(withExtension: Bool) -> String {
        let base = customExportFilename
            ?? doc.filenameWithoutExtension?.appending("-processed")
            ?? "File"
        return withExtension ? base + ".pdf" : base
    }
    
    func set(filenameForExportWithoutExtension filename: String?) {
        customExportFilename = filename
    }
    
    /// Return the consolidated filename for filename text matching logic, without file extension.
    var filenameForMatching: String {
        customExportFilename
            ?? doc.filenameWithoutExtension
            ?? ""
    }
    
    /// Returns `true` if a custom file name was set.
    var hasCustomExportFilename: Bool {
        customExportFilename != nil
    }
}

#endif
