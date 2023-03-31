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
    /// Filter page(s).
    func performFilterPages(fileIndex: Int, pages: PDFPageFilter) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: fileIndex)
        
        let diff = try pdf.pageIndexes(filter: pages)
        
        guard !diff.isIdentical else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        try pdf.removePages(at: diff.excluded)
        
        return .changed
    }
    
    /// Reverse the pages in a file.
    func performReversePageOrder(fileIndex: Int) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: fileIndex)
        
        let pages = try pdf.pages()
        
        guard pages.count > 1 else {
            let plural = "page\(pages.count == 1 ? "" : "s")"
            return .noChange(reason: "Reversing pages has no effect because file only has \(pages.count) \(plural).")
        }
        
        try pdf.replaceAllPages(with: pages.reversed())
        
        return .changed
    }
    
    /// Replace page(s) with other page(s).
    func performReplacePages(
        fromFileIndex: Int,
        fromPages: PDFPageFilter,
        toFileIndex: Int,
        toPages: PDFPageFilter
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectTwoFiles(indexA: fromFileIndex, indexB: toFileIndex)
        
        let pdfAIndexes = try pdfA.pageIndexes(filter: toPages)
        let pdfBIndexes = try pdfB.pageIndexes(filter: toPages)
        
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
    
    /// Sets the rotation angle for the page in degrees.
    func performRotatePages(
        fileIndex: Int,
        filter: PDFPageFilter,
        rotation: PDFPageRotation
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: fileIndex)
        
        let pdfAIndexes = try pdf.pageIndexes(filter: filter)
        
        guard pdfAIndexes.isInclusive else {
            throw PDFToolError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        for index in pdfAIndexes.included {
            guard let page = pdf.page(at: index) else {
                throw PDFToolError.runtimeError(
                    "Page number \(index + 1) of file index \(fileIndex) could not be read."
                )
            }
            let sourceAngle = PDFPageRotation.Angle(degrees: page.rotation) ?? ._0degrees
            page.rotation = rotation.degrees(offsetting: sourceAngle)
        }
        
        return .changed
    }
    
    func performRemoveAnnotations(
        fileIndex: Int,
        filter: PDFPageFilter
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(index: fileIndex)
        
        let pdfAIndexes = try pdf.pageIndexes(filter: filter)
        
        guard pdfAIndexes.isInclusive else {
            throw PDFToolError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        for index in pdfAIndexes.included {
            guard let page = pdf.page(at: index) else {
                throw PDFToolError.runtimeError(
                    "Page number \(index + 1) of file index \(fileIndex) could not be read."
                )
            }
            let annotations = page.annotations
            for annotation in annotations {
                page.removeAnnotation(annotation)
            }
            
            guard page.annotations.isEmpty else {
                throw PDFToolError.runtimeError(
                    "Could not remove all annotations for page number \(index + 1) of file index \(file)."
                )
            }
        }
        
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
