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
    /// Filter PDF file(s).
    func performFilterFiles(files: PDFFilesDescriptor) throws -> PDFOperationResult {
        let filteredPDFs = try expectZeroOrMoreFiles(files)
        let sourcePDFs = pdfs
        
        pdfs = filteredPDFs
        
        if sourcePDFs != filteredPDFs {
            return .changed
        } else {
            return .noChange(reason: "Filtered files are identical to input.")
        }
    }
    
    /// Merge all PDF file(s) sequentially into a single PDF file.
    /// If target file is `nil`, the first file is used as the target and the contents of subsequent
    /// files are appended to it.
    /// - Note: The target file will always be removed from the set of source file(s).
    ///   This then allows the use of `.all` input files without encountering an error condition.
    /// - Note: Source file(s) not matching the input descriptor are discarded.
    func performMergeFiles(
        files: PDFFilesDescriptor,
        appendingTo targetFile: PDFFileDescriptor? = nil
    ) throws -> PDFOperationResult {
        var filteredPDFs = try expectZeroOrMoreFiles(.all)
        
        guard filteredPDFs.count > 1 else {
            return .noChange(reason: "Not enough source files to perform merge.")
        }
        
        guard let targetPDF = targetFile != nil
            ? try expectOneFile(targetFile!)
            : filteredPDFs.first
        else {
            throw PDFToolError.runtimeError("Could not determine file to append to.")
        }
        
        // ensure the target PDF is not a member of the source PDFs
        filteredPDFs.removeAll(targetPDF)
        
        // check count again
        guard filteredPDFs.count > 0 else {
            return .noChange(reason: "Not enough source files to perform merge.")
        }
        
        for pdf in filteredPDFs {
            try targetPDF.append(pages: pdf.pages(for: .all).map { $0.copy() as! PDFPage })
        }
        
        pdfs = [targetPDF]
        
        return .changed
    }
    
    /// Filter page(s).
    func performFilterPages(file: PDFFileDescriptor, pages: PDFPageFilter) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let diff = try pdf.pageIndexes(filter: pages)
        
        guard !diff.isIdentical else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        try pdf.removePages(at: diff.excluded)
        
        return .changed
    }
    
    /// Reverse the pages in a file.
    func performReversePageOrder(file: PDFFileDescriptor) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let pages = try pdf.pages()
        
        guard pages.count > 1 else {
            let plural = "page\(pages.count == 1 ? "" : "s")"
            return .noChange(reason: "Reversing pages has no effect because file only has \(pages.count) \(plural).")
        }
        
        try pdf.replaceAllPages(with: pages.reversed())
        
        return .changed
    }
    
    /// Replace page(s) with a copy of other page(s) either within the same file or between two files.
    func performReplacePages(
        from sourceFile: PDFFileDescriptor,
        fromPages: PDFPageFilter,
        to destFile: PDFFileDescriptor?,
        toPages: PDFPageFilter
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectSourceAndDestinationFiles(sourceFile, destFile ?? sourceFile)
        
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
                if pdfA == pdfB {
                    pdfB.exchangePage(at: indexes.1, withPageAt: indexes.0)
                } else {
                    let pdfAPageCopy = pdfAPage.copy() as! PDFPage
                    try pdfB.exchangePage(at: indexes.1, withPage: pdfAPageCopy)
                }
            }
        
        pdfs = [pdfB]
        
        return .changed
    }
    
    /// Sets the rotation angle for the page in degrees.
    func performRotatePages(
        file: PDFFileDescriptor,
        pages: PDFPageFilter,
        rotation: PDFPageRotation
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let pdfAIndexes = try pdf.pageIndexes(filter: pages)
        
        guard pdfAIndexes.isInclusive else {
            throw PDFToolError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        for index in pdfAIndexes.included {
            guard let page = pdf.page(at: index) else {
                throw PDFToolError.runtimeError(
                    "Page number \(index + 1) of \(file) could not be read."
                )
            }
            let sourceAngle = PDFPageRotation.Angle(degrees: page.rotation) ?? ._0degrees
            page.rotation = rotation.degrees(offsetting: sourceAngle)
        }
        
        return .changed
    }
    
    /// Filter annotations by type.
    func performFilterAnnotations(
        file: PDFFileDescriptor,
        pages: PDFPageFilter,
        annotations: PDFAnnotationFilter
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let pdfAIndexes = try pdf.pageIndexes(filter: pages)
        
        guard pdfAIndexes.isInclusive else {
            throw PDFToolError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        for index in pdfAIndexes.included {
            guard let page = pdf.page(at: index) else {
                throw PDFToolError.runtimeError(
                    "Page number \(index + 1) of \(file) could not be read."
                )
            }
            
            let preCount = page.annotations.count
            var filteredCount = preCount
            for annotation in page.annotations {
                if !annotations.contains(annotation) {
                    filteredCount -= 1
                    page.removeAnnotation(annotation)
                }
            }
            let postCount = page.annotations.count
            
            guard postCount == filteredCount else {
                throw PDFToolError.runtimeError(
                    "Could not remove \(annotations) annotations for page number \(index + 1) of \(file)."
                )
            }
        }
        
        return .changed
    }
}

// MARK: - Helpers

extension PDFTool {
    func expectOneFile(
        _ descriptor: PDFFileDescriptor,
        error: String? = nil
    ) throws -> PDFDocument {
        guard let file = descriptor.first(in: pdfs) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file: \(descriptor.verboseDescription)."
            )
        }
        
        return file
    }
    
    func expectSourceAndDestinationFiles(
        _ descriptorA: PDFFileDescriptor,
        _ descriptorB: PDFFileDescriptor,
        error: String? = nil
    ) throws -> (pdfA: PDFDocument, pdfB: PDFDocument) {
        guard let fileA = descriptorA.first(in: pdfs) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file: \(descriptorA)."
            )
        }
        guard let fileB = descriptorB.first(in: pdfs) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF file: \(descriptorB)."
            )
        }
        
        return (pdfA: fileA, pdfB: fileB)
    }
    
    func expectZeroOrMoreFiles(
        _ descriptor: PDFFilesDescriptor,
        error: String? = nil
    ) throws -> [PDFDocument] {
        guard let files = descriptor.filtering(pdfs) else {
            throw PDFToolError.runtimeError(
                error ?? "Missing input PDF files: \(descriptor.verboseDescription)."
            )
        }
        
        return files
    }
}
