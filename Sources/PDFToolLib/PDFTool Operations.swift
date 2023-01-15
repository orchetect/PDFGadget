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
        
        let diff = try pdf.pageIndexes(filter: filter)
        
        guard !diff.isIdentical else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        try pdf.removePages(at: diff.excluded)
        
        return .changed
    }
    
    func performReversePageOrder() throws -> PDFOperationResult {
        let pdf = try expectOneFile()
        
        let pages = try pdf.pages().reversed()
        try pdf.replaceAllPages(with: pages)
        
        return .changed
    }
    
    func performReplacePages(
        from fromFilter: PDFPageFilter,
        to toFilter: PDFPageFilter
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectTwoFiles()
        
        let pdfAIndexes = try pdfA.pageIndexes(filter: toFilter)
        let pdfBIndexes = try pdfB.pageIndexes(filter: toFilter)
        
        // TODO: could have an exception for when toFilter is .all to always allow it
        
        guard pdfAIndexes.isInclusive, pdfBIndexes.isInclusive else {
            throw PDFToolError.runtimeError(
                "Page number descriptors are invalid or out of range."
            )
        }
        
        guard pdfAIndexes.included.count == pdfBIndexes.included.count else {
            let a = pdfAIndexes.included.count
            let b = pdfBIndexes.included.count
            throw PDFToolError.runtimeError(
                "Selected page counts for replacement do not match: \(a) pages from file A to \(b) pages in file B."
            )
        }
        
        let pdfAPages = try pdfA.pages(at: pdfAIndexes.included)
        
        try zip(pdfAPages, pdfBIndexes.included)
            .forEach { pdfAPage, pdfBIndex in
                try pdfB.exchangePage(at: pdfBIndex, withPage: pdfAPage)
            }
        
        pdfs = [pdfB]
        
        return .changed
    }
}

// MARK: - Helpers

extension PDFTool {
    func expectOneFile(
        error: String? = nil
    ) throws -> PDFDocument {
        guard pdfs.count == 1 else {
            throw PDFToolError.runtimeError(
                error ?? "Expected one input PDF file."
            )
        }
        
        return pdfs[0]
    }
    
    func expectTwoFiles(
        error: String? = nil
    ) throws -> (pdfA: PDFDocument, pdfB: PDFDocument) {
        guard pdfs.count == 2 else {
            throw PDFToolError.runtimeError(
                error ?? "Expected two input PDF files."
            )
        }
        
        return (pdfA: pdfs[0], pdfB: pdfs[1])
    }
}
