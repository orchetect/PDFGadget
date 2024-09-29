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
    private var _customExportFilename: String?
    
    init(doc: PDFDocument, customExportFilename: String? = nil) {
        self.doc = doc
        _customExportFilename = customExportFilename
    }
    
    /// Return the consolidated filename for export, without file extension.
    var filenameForExport: String {
        _customExportFilename
            ?? doc.filenameWithoutExtension?.appending("-processed")
            ?? "File"
    }
    
    func set(filenameForExport: String?) {
        _customExportFilename = filenameForExport
    }
    
    /// Return the consolidated filename for filename text matching logic, without file extension.
    var filenameForMatching: String {
        _customExportFilename
            ?? doc.filenameWithoutExtension
            ?? ""
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
            customExportFilename: _customExportFilename
        )
    }
}

#endif
