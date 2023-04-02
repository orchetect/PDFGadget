//
//  PDFGadget Operations.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import Logging
import OTCore
import PDFKit

extension PDFGadget {
    /// New empty PDF files.
    func performNewFile() throws -> PDFOperationResult {
        pdfs.append(newEmptyPDFFile())
        return .changed
    }
    
    /// Clone PDF file.
    func performCloneFile(file: PDFFileDescriptor) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        pdfs.append(pdf.copy() as! PDFFile)
        
        return .changed
    }
    
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
        var filteredPDFs = try expectZeroOrMoreFiles(files)
        
        guard let targetPDF = targetFile != nil
            ? try expectOneFile(targetFile!)
            : filteredPDFs.first
        else {
            throw PDFGadgetError.runtimeError("Could not determine file to append to.")
        }
        
        // ensure the target PDF is not a member of the source PDFs
        filteredPDFs.removeAll(targetPDF)
        
        // check count again
        guard filteredPDFs.count > 0 else {
            return .noChange(reason: "Not enough source files to perform merge.")
        }
        
        for pdf in filteredPDFs {
            try targetPDF.doc.append(pages: pdf.doc.pages(for: .all, copy: true))
            pdfs.removeAll(pdf)
        }
        
        return .changed
    }
    
    /// Set new filename for a PDF file.
    func performSetFilename(
        file: PDFFileDescriptor,
        filename: String?
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let oldFilename = pdf.filenameForExport
        
        pdf.set(filenameForExport: filename)
        
        return filename == oldFilename
            ? .noChange(reason: "New filename is identical to old filename.")
            : .changed
    }
    
    /// Filter page(s).
    func performFilterPages(file: PDFFileDescriptor, pages: PDFPagesFilter) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let diff = try pdf.doc.pageIndexes(filter: pages)
        
        guard !diff.isIdentical else {
            return .noChange(reason: "Filtered page numbers are identical to input.")
        }
        
        try pdf.doc.removePages(at: diff.excluded)
        
        return .changed
    }
    
    /// Insert page(s) with a copy of other page(s) either within the same file or between two files.
    func performInsertPages(
        from sourceFile: PDFFileDescriptor,
        fromPages: PDFPagesFilter,
        to destFile: PDFFileDescriptor?,
        toPageIndex: Int?,
        behavior: PDFOperation.InterchangeBehavior
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectSourceAndDestinationFiles(sourceFile, destFile ?? sourceFile)
        
        let pdfAIndexes = try pdfA.doc.pageIndexes(filter: fromPages)
        
        guard pdfAIndexes.isInclusive else {
            throw PDFGadgetError.runtimeError(
                "Page number descriptors are invalid or out of range."
            )
        }
        
        // append to end of file if index is nil
        let targetPageIndex = toPageIndex ?? pdfB.doc.pageCount
        
        let pdfAPages = try pdfA.doc.pages(at: pdfAIndexes.included, copy: pdfA != pdfB)
        try pdfB.doc.insert(pdfAPages, at: targetPageIndex)
        
        if behavior == .move {
            try pdfA.doc.removePages(at: pdfAIndexes.included)
        }
        
        return .changed
    }
    
    /// Reverse the pages in a file.
    func performReversePageOrder(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let pageIndexes = try pdf.doc.pageIndexes(filter: pages)
        
        guard pageIndexes.isInclusive else {
            throw PDFGadgetError.runtimeError(
                "Page number descriptors are invalid or out of range."
            )
        }
        
        let indexesToReverse = pageIndexes.included
        
        guard indexesToReverse.count > 1 else {
            let plural = "page\(indexesToReverse.count == 1 ? " is" : "s are")"
            return .noChange(reason: "Reversing pages has no effect because file only has \(indexesToReverse.count) \(plural) selected for reversal.")
        }
        
        let pairs = zip(indexesToReverse, indexesToReverse.reversed())
            .prefix(indexesToReverse.count / 2)
        
        for (srcIndex, destIndex) in pairs {
            pdf.doc.exchangePage(at: srcIndex, withPageAt: destIndex)
        }
        
        return .changed
    }
    
    /// Replace page(s) with a copy of other page(s) either within the same file or between two files.
    func performReplacePages(
        from sourceFile: PDFFileDescriptor,
        fromPages: PDFPagesFilter,
        to destFile: PDFFileDescriptor?,
        toPages: PDFPagesFilter,
        behavior: PDFOperation.InterchangeBehavior
    ) throws -> PDFOperationResult {
        let (pdfA, pdfB) = try expectSourceAndDestinationFiles(sourceFile, destFile ?? sourceFile)
        
        let pdfAIndexes = try pdfA.doc.pageIndexes(filter: fromPages)
        let pdfBIndexes = try pdfB.doc.pageIndexes(filter: toPages)
        
        // TODO: could have an exception for when toFilter is .all to always allow it
        
        guard pdfAIndexes.isInclusive, pdfBIndexes.isInclusive else {
            throw PDFGadgetError.runtimeError(
                "Page number descriptors are invalid or out of range."
            )
        }
        
        guard pdfAIndexes.included.count == pdfBIndexes.included.count else {
            let a = pdfAIndexes.included.count
            let b = pdfBIndexes.included.count
            throw PDFGadgetError.runtimeError(
                "Selected page counts for replacement do not match: \(a) pages from file A to \(b) pages in file B."
            )
        }
        
        let pdfAPages = try pdfA.doc.pages(at: pdfAIndexes.included)
        
        try zip(pdfAPages, zip(pdfAIndexes.included, pdfBIndexes.included))
            .forEach { pdfAPage, indexes in
                if pdfA == pdfB {
                    // behavior has no effect for same-file operations
                    pdfB.doc.exchangePage(at: indexes.1, withPageAt: indexes.0)
                } else {
                    try pdfB.doc.exchangePage(at: indexes.1, withPage: pdfAPage, copy: true)
                }
            }
        
        if behavior == .move {
            try pdfA.doc.removePages(at: pdfAIndexes.included)
        }
        
        return .changed
    }
    
    /// Sets the rotation angle for the page in degrees.
    func performRotatePages(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        rotation: PDFPageRotation
    ) throws -> PDFOperationResult {
        try performPagesTransform(file: file, pages: pages) { page, _ in
            let sourceAngle = PDFPageRotation.Angle(degrees: page.rotation) ?? ._0degrees
            page.rotation = rotation.degrees(offsetting: sourceAngle)
        }
    }
    
    /// Split a single PDF file into multiple files.
    func performSplitFile(
        file: PDFFileDescriptor,
        discardUnused: Bool,
        splits: PDFFileSplitDescriptor
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        var remainingPageIndexes: [Int] = pdf.doc.pageIndexes()
        
        let newSplits = splits.splits(source: pdf)
        
        guard !newSplits.isEmpty else {
            return .noChange(reason: "File split descriptor does not result in multiple files.")
        }
        
        var dedupeFilenameCount = 0
        for split in newSplits {
            let pages = try pdf.doc.pages(at: split.pageRange, copy: true)
            let newFile = newEmptyPDFFile()
            
            if let filename = split.filename {
                newFile.set(filenameForExport: filename)
            } else {
                newFile.set(filenameForExport: newFile.filenameForExport + "-split\(dedupeFilenameCount)")
                dedupeFilenameCount += 1
            }
            newFile.doc.append(pages: pages)
            pdfs.append(newFile)
            remainingPageIndexes.removeAll(where: { split.pageRange.contains($0) })
        }
        
        func removeSourceFile() { pdfs.removeAll(pdf) }
        
        // some logic and user feedback regarding source file and page utilization
        let remainingPageNumbersString = remainingPageIndexes.map { String($0 + 1) }.joined(separator: ", ")
        if discardUnused {
            if !remainingPageIndexes.isEmpty {
                logger.info(
                    "Note: Split source file will be discarded, but page numbers \(remainingPageNumbersString) were unused."
                )
            }
            removeSourceFile()
        } else {
            if remainingPageIndexes.isEmpty {
                logger.info("Removing split source file; all pages were split into new file(s).")
                removeSourceFile()
            } else {
                // source file has at least one unused page remaining
                logger.info("Split source file still contains unused page numbers \(remainingPageNumbersString).")
                
                // remove used pages
                let usedIndexes = pdf.doc.pageIndexes().filter { !remainingPageIndexes.contains($0) }
                try pdf.doc.removePages(at: usedIndexes)
            }
        }
        
        return .changed
    }
    
    /// Filter annotations by type.
    func performFilterAnnotations(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        annotations: PDFAnnotationFilter
    ) throws -> PDFOperationResult {
        try performPagesTransform(file: file, pages: pages) { page, pageDescription in
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
                throw PDFGadgetError.runtimeError(
                    "Could not remove \(annotations) annotations for \(pageDescription)."
                )
            }
        }
    }
}

// MARK: - Helpers

extension PDFGadget {
    func newEmptyPDFFile() -> PDFFile {
        PDFFile(doc: PDFDocument())
    }
    
    func expectOneFile(
        _ descriptor: PDFFileDescriptor,
        error: String? = nil
    ) throws -> PDFFile {
        guard let file = descriptor.first(in: pdfs) else {
            throw PDFGadgetError.runtimeError(
                error ?? "Missing input PDF file: \(descriptor.verboseDescription)."
            )
        }
        
        return file
    }
    
    func expectSourceAndDestinationFiles(
        _ descriptorA: PDFFileDescriptor,
        _ descriptorB: PDFFileDescriptor,
        error: String? = nil
    ) throws -> (pdfA: PDFFile, pdfB: PDFFile) {
        guard let fileA = descriptorA.first(in: pdfs) else {
            throw PDFGadgetError.runtimeError(
                error ?? "Missing input PDF file: \(descriptorA)."
            )
        }
        guard let fileB = descriptorB.first(in: pdfs) else {
            throw PDFGadgetError.runtimeError(
                error ?? "Missing input PDF file: \(descriptorB)."
            )
        }
        
        return (pdfA: fileA, pdfB: fileB)
    }
    
    func expectZeroOrMoreFiles(
        _ descriptor: PDFFilesDescriptor,
        error: String? = nil
    ) throws -> [PDFFile] {
        guard let files = descriptor.filtering(pdfs) else {
            throw PDFGadgetError.runtimeError(
                error ?? "Missing input PDF files: \(descriptor.verboseDescription)."
            )
        }
        
        return files
    }
    
    /// Generic wrapper for transforming page(s).
    func performPagesTransform(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        transform: (_ page: PDFPage, _ pageDescription: String) throws -> Void
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        let pdfIndexes = try pdf.doc.pageIndexes(filter: pages)
        
        guard pdfIndexes.isInclusive else {
            throw PDFGadgetError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        for index in pdfIndexes.included {
            guard let page = pdf.doc.page(at: index) else {
                throw PDFGadgetError.runtimeError(
                    "Page number \(index + 1) of \(file) could not be read."
                )
            }
            try transform(page, "page number \(index + 1) of \(file)")
        }
        
        return .changed
    }
}

#endif
