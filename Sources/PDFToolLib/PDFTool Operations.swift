//
//  PDFTool Operations.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import AppKit
import Logging
import OTCore
import PDFKit

extension PDFTool {
    func performFilterPages(filter: PDFPageFilter) throws -> PDFOperationResult {
        let pdf = try expectOneFile()
        
        let originalIndexes = pdf.pageIndexes
        let filteredIndexes = filter.apply(to: originalIndexes)
        
        guard filteredIndexes != originalIndexes else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        #warning("> finish operation")
        return .noChange(reason: "Feature not yet implemented.")
    }
    
    func performReversePageOrder() throws -> PDFOperationResult {
        let pdf = try expectOneFile()
        
        let pages = try pdf.pages().reversed()
        try pdf.replaceAllPages(with: pages)
        
        return .changed
    }
    
    func performReplacePages(
        fromFile1: PDFPageFilter,
        toFile2: PDFPageFilter
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectTwoFiles()
        
        #warning("> not done yet")
        return .noChange(reason: "Feature not yet implemented.")
    }
}

// MARK: - Helpers

extension PDFTool {
    func expectOneFile() throws -> PDFDocument {
        guard pdfs.count == 1 else {
            throw PDFToolError.runtimeError(
                "Expected one input PDF file."
            )
        }
        
        return pdfs[0]
    }
    
    func expectTwoFiles() throws -> (pdfA: PDFDocument, pdfB: PDFDocument) {
        guard pdfs.count == 2 else {
            throw PDFToolError.runtimeError(
                "Expected two input PDF files."
            )
        }
        
        return (pdfA: pdfs[0], pdfB: pdfs[1])
    }
}
