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
    func performFilterPages(file: Int, filter: PDFPageFilter) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: file)
        
        let diff = try pdf.pageIndexes(filter: filter)
        
        guard !diff.isIdentical else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        try pdf.removePages(at: diff.excluded)
        
        return .changed
    }
    
    func performReversePageOrder(file: Int) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: file)
        
        let pages = try pdf.pages().reversed()
        try pdf.replaceAllPages(with: pages)
        
        return .changed
    }
    
    func performReplacePages(
        fromFileIndex: Int,
        fromFilter: PDFPageFilter,
        toFileIndex: Int,
        toFilter: PDFPageFilter
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectTwoFiles(indexA: fromFileIndex, indexB: toFileIndex)
        
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
        
        try zip(pdfAPages, zip(pdfAIndexes.included, pdfBIndexes.included))
            .forEach { pdfAPage, indexes in
                let pageCopy = pdfAPage.copy() as! PDFPage
                try pdfB.exchangePage(at: indexes.1, withPage: pageCopy)
                pdfA.removePage(at: indexes.0)
            }
        
        pdfs = [pdfB]
        
        return .changed
    }
}

// MARK: - Helpers

extension PDFTool {
    func expectOneFile(
        index: Int,
        error: String? = nil
    ) throws -> PDFDocument {
        guard pdfs.count >= index else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file indexed \(index)."
            )
        }
        
        return pdfs[index]
    }
    
    func expectTwoFiles(
        indexA: Int,
        indexB: Int,
        error: String? = nil
    ) throws -> (pdfA: PDFDocument, pdfB: PDFDocument) {
        guard pdfs.indices.contains(indexA) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file index \(indexA)."
            )
        }
        guard pdfs.indices.contains(indexB) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file index \(indexB)."
            )
        }
        
        return (pdfA: pdfs[indexA], pdfB: pdfs[indexB])
    }
}
