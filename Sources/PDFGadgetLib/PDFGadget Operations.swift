//
//  PDFGadget Operations.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
internal import OTCore
import PDFKit

extension PDFGadget {
    /// New empty PDF files.
    func performNewFile() throws -> PDFOperationResult {
        pdfs.append(PDFFile())
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
        guard !filteredPDFs.isEmpty else {
            return .noChange(reason: "Not enough source files to perform merge.")
        }
        
        for pdf in filteredPDFs {
            try targetPDF.doc.append(pages: pdf.doc.pages(for: .all, copy: true))
            pdfs.removeAll(pdf)
        }
        
        return .changed
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
            let newFile = PDFFile()
            
            if let filename = split.filename {
                newFile.set(filenameForExportWithoutExtension: filename)
            } else {
                let newFilename = newFile.filenameForExport(withExtension: false)
                    + "-split\(dedupeFilenameCount)"
                newFile.set(filenameForExportWithoutExtension: newFilename)
                dedupeFilenameCount += 1
            }
            newFile.doc.append(pages: pages)
            pdfs.append(newFile)
            remainingPageIndexes.removeAll(where: { split.pageRange.contains($0) })
        }
        
        func removeSourceFile() { pdfs.removeAll(pdf) }
        
        // some logic and user feedback regarding source file and page utilization
        let remainingPageNumbersString = remainingPageIndexes
            .map { String($0 + 1) }
            .joined(separator: ", ")
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
                logger.info(
                    "Split source file still contains unused page numbers \(remainingPageNumbersString)."
                )
                
                // remove used pages
                let usedIndexes = pdf.doc.pageIndexes()
                    .filter { !remainingPageIndexes.contains($0) }
                try pdf.doc.removePages(at: usedIndexes)
            }
        }
        
        return .changed
    }
    
    /// Set new filename for a PDF file. Passing `nil` resets the filename.
    func performSetFilename(
        file: PDFFileDescriptor,
        filename: String?
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        return try performSetFilename(file: pdf, filename: filename)
    }
    
    /// Utility for `performSetFilename(file:filename:)`
    private func performSetFilename(
        file pdf: PDFFile,
        filename: String?
    ) throws -> PDFOperationResult {
        let oldFilename = pdf.filenameForExport(withExtension: false)
        
        pdf.set(filenameForExportWithoutExtension: filename)
        
        return filename == oldFilename
            ? .noChange(reason: "New filename is identical to old filename.")
            : .changed
    }
    
    /// Set new filenames for one or more PDF files. Passing `nil` resets a filename.
    func performSetFilenames(
        files: PDFFilesDescriptor,
        filenames: [String?]
    ) throws -> PDFOperationResult {
        let pdfs = try expectZeroOrMoreFiles(files)
        
        guard !pdfs.isEmpty else {
            return .noChange(reason: "No files specified.")
        }
        
        guard filenames.count == pdfs.count else {
            throw PDFGadgetError.runtimeError(
                "Failed to set filenames; the resulting number of files does not match the supplied number of filenames."
            )
        }
        
        var result: PDFOperationResult = .noChange(reason: "All filenames are identical to old filenames.")
        
        for (pdf, filename) in zip(pdfs, filenames) {
            let singleFileResult = try performSetFilename(file: pdf, filename: filename)
            if case .changed = singleFileResult {
                result = .changed
            }
        }
        
        return result
    }
    
    /// Remove metadata (attributes) from one or more files.
    func performRemoveFileAttributes(
        files: PDFFilesDescriptor
    ) throws -> PDFOperationResult {
        try performTransform(files: files) { pdf, _ in
            var isChanged = false
            
            // setting nil doesn't work, have to set empty dictionary instead
            if pdf.doc.documentAttributes?.isEmpty == false {
                pdf.doc.documentAttributes = [:]
                isChanged = true
            }
            // validation check
            guard pdf.doc.documentAttributes == nil
                || pdf.doc.documentAttributes?.isEmpty == true
            else {
                throw PDFGadgetError.runtimeError(
                    "Failed to remove attributes for \(pdf)."
                )
            }
            
            return isChanged ? .changed : .noChange(reason: "No attributes were found.")
        }
    }
    
    /// Set an attribute's value for one or more files.
    func performSetFileAttribute(
        files: PDFFilesDescriptor,
        attribute: PDFDocumentAttribute,
        value: String?
    ) throws -> PDFOperationResult {
        try performTransform(files: files) { pdf, _ in
            var isChanged = false
            
            if pdf.doc.documentAttributes == nil {
                pdf.doc.documentAttributes = [:]
            }
            
            func assignValue() {
                pdf.doc.documentAttributes?[attribute] = value
                isChanged = true
            }
            
            if let existingValue = pdf.doc.documentAttributes?[attribute] as? String {
                if existingValue != value {
                    assignValue()
                }
            } else {
                assignValue()
            }
            
            return isChanged ? .changed : .noChange(reason: "Value(s) are identical.")
        }
    }
    
    /// Filter page(s).
    func performFilterPages(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter
    ) throws -> PDFOperationResult {
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
            return .noChange(
                reason: "Reversing pages has no effect because file only has \(indexesToReverse.count) \(plural) selected for reversal."
            )
        }
        
        let pairs = zip(indexesToReverse, indexesToReverse.reversed())
            .prefix(indexesToReverse.count / 2)
        
        for (srcIndex, destIndex) in pairs {
            pdf.doc.exchangePage(at: srcIndex, withPageAt: destIndex)
        }
        
        return .changed
    }
    
    /// Sets the rotation angle for the page in degrees.
    func performRotatePages(
        files: PDFFilesDescriptor,
        pages: PDFPagesFilter,
        rotation: PDFPageRotation
    ) throws -> PDFOperationResult {
        try performTransform(files: files, pages: pages) { page, _ in
            let originalPageRotation = page.rotation
            
            let sourceAngle = PDFPageRotation.Angle(degrees: page.rotation) ?? ._0degrees
            let newPageRotation = rotation.degrees(offsetting: sourceAngle)
            page.rotation = newPageRotation
            
            return originalPageRotation != newPageRotation
                ? .changed
                : .noChange(reason: nil)
        }
    }
    
    func performCropPages(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        area: PDFPageArea,
        process: PDFOperation.ValueModification
    ) throws -> PDFOperationResult {
        try performTransform(file: file, pages: pages) { page, _ in
            let originalCropBox = page.bounds(for: .cropBox)
            
            let bounds = switch process {
            case .absolute: page.bounds(for: .mediaBox)
            case .relative: page.bounds(for: .cropBox)
            }
            let rotationAngle = PDFPageRotation.Angle(degrees: page.rotation) ?? ._0degrees
            let newCropBox = area.rect(for: bounds, rotation: rotationAngle)
            page.setBounds(newCropBox, for: .cropBox)
            
            return originalCropBox != newCropBox
                ? .changed
                : .noChange(reason: nil)
        }
    }
    
    /// Filter annotations by type.
    func performFilterAnnotations(
        files: PDFFilesDescriptor,
        pages: PDFPagesFilter,
        annotations: PDFAnnotationFilter
    ) throws -> PDFOperationResult {
        try performTransform(files: files, pages: pages) { page, pageDescription in
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
            
            return preCount != postCount
                ? .changed
                : .noChange(reason: nil)
        }
    }
    
    @available(macOS 13.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    func performBurnInAnnotations(
        files: PDFFilesDescriptor
    ) throws -> PDFOperationResult {
        try performTransform(files: files) { pdf, _ in
            if !pdf.writeOptions.keys.contains(.burnInAnnotationsOption) {
                pdf.writeOptions[.burnInAnnotationsOption] = true
                return .changed
            } else {
                return .noChange(reason: "Option already set.")
            }
        }
    }
    
    func performExtractPlainText(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        to destination: PDFTextDestination,
        pageBreak: PDFTextPageBreak
    ) throws -> PDFOperationResult {
        let noChangeReason = "Reading plain text."
        
        var pageTexts: [String] = []
        
        // discard result since this is a read-only operation
        let _ = try performTransform(file: file, pages: pages) { page, pageDescription in
            guard let pageText = page.string else {
                return .noChange(reason: noChangeReason)
            }
            pageTexts.append(pageText)
            return .noChange(reason: noChangeReason)
        }
        
        let fullText = pageTexts.joined(separator: pageBreak.rawValue)
        
        switch destination {
        case .pasteboard:
            #if !os(tvOS) && !os(watchOS)
            if !fullText.copyToClipboard() {
                throw PDFGadgetError.runtimeError(
                    "Error while attempting to copy text to pasteboard."
                )
            }
            #else
            throw PDFGadgetError.runtimeError(
                "Copy text to pasteboard operation is unavailable on the current platform."
            )
            #endif
            
        case let .file(url):
            try fullText.write(to: url, atomically: false, encoding: .utf8)
            
        case let .variable(named: variableName):
            variables[variableName] = .string(fullText)
        }
        
        return .noChange(reason: noChangeReason)
    }
    
    func performRemoveProtections(
        files: PDFFilesDescriptor
    ) throws -> PDFOperationResult {
        let files = try expectZeroOrMoreFiles(files)
        
        guard !files.isEmpty else {
            return .noChange()
        }
        
        for file in files {
            // TODO: add checks to see if file has permissions set first, and skip removing protections if unnecessary and return `.noChange`
            
            let originalFilenameForExport = file.filenameForExport(withExtension: false)
            let unprotectedFile = try file.doc.unprotectedCopy()
            file.doc = unprotectedFile
            
            // new PDFDocument does not inherit `documentURL` so we will set its custom filename
            // since `documentURL` is a read-only property
            if !file.hasCustomExportFilename {
                file.set(filenameForExportWithoutExtension: originalFilenameForExport)
            }
        }
        
        return .changed
    }
}

// MARK: - Helpers

extension PDFGadget {
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
    func performTransform(
        files: PDFFilesDescriptor,
        transform: (_ file: PDFFile, _ pageDescription: String) throws -> PDFOperationResult
    ) throws -> PDFOperationResult {
        let pdfs = try expectZeroOrMoreFiles(files)
        
        guard !pdfs.isEmpty else {
            return .noChange(reason: "No files specified.")
        }
        
        var returnResult: PDFOperationResult = .noChange(reason: nil)
        
        for pdf in pdfs {
            let result = try transform(pdf, "file \(pdf)")
            if returnResult != .changed { returnResult = result }
        }
        
        return returnResult
    }
    
    /// Generic wrapper for transforming page(s).
    func performTransform(
        files: PDFFilesDescriptor,
        pages: PDFPagesFilter,
        transform: (_ page: PDFPage, _ pageDescription: String) throws -> PDFOperationResult
    ) throws -> PDFOperationResult {
        let pdfs = try expectZeroOrMoreFiles(files)
        
        guard !pdfs.isEmpty else {
            return .noChange(reason: "No files specified.")
        }
        
        var returnResult: PDFOperationResult = .noChange(reason: nil)
        
        for pdf in pdfs {
            let result = try performTransform(file: pdf, pages: pages, transform: transform)
            if returnResult != .changed { returnResult = result }
        }
        
        return returnResult
    }
    
    /// Generic wrapper for transforming page(s).
    func performTransform(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        transform: (_ page: PDFPage, _ pageDescription: String) throws -> PDFOperationResult
    ) throws -> PDFOperationResult {
        let pdf = try expectOneFile(file)
        
        return try performTransform(file: pdf, pages: pages, transform: transform)
    }
    
    /// Generic wrapper for transforming page(s).
    func performTransform(
        file pdf: PDFFile,
        pages: PDFPagesFilter,
        transform: (_ page: PDFPage, _ pageDescription: String) throws -> PDFOperationResult
    ) throws -> PDFOperationResult {
        let pdfIndexes = try pdf.doc.pageIndexes(filter: pages)
        
        guard pdfIndexes.isInclusive else {
            throw PDFGadgetError.runtimeError(
                "Page number descriptor is invalid or out of range."
            )
        }
        
        var returnResult: PDFOperationResult = .noChange(reason: nil)
        
        for index in pdfIndexes.included {
            guard let page = pdf.doc.page(at: index) else {
                throw PDFGadgetError.runtimeError(
                    "Page number \(index + 1) of \(pdf) could not be read."
                )
            }
            let result = try transform(page, "page number \(index + 1) of \(pdf)")
            if returnResult != .changed { returnResult = result }
        }
        
        return returnResult
    }
}

#endif
