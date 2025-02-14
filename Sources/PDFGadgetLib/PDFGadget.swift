//
//  PDFGadget.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import os.log
internal import OTCore
import PDFKit

/// PDF editing toolkit offering declarative batch file & page operations.
public final class PDFGadget {
    let logger = Logger(subsystem: "com.orchetect.PDFGadget", category: "Gadget")
    
    var pdfs: [PDFFile] = []
    
    public var pdfDocuments: [PDFDocument] {
        pdfs.map(\.doc)
    }
    
    /// Temporary storage for PDF operations, keyed by the variable name.
    public var variables: [String: VariableContent] = [:]
    
    public init() { }
    
    public init(pdfs: [PDFDocument]) {
        self.pdfs = pdfs.map { PDFFile(doc: $0) }
    }
    
    public init(pdfs: [URL]) throws {
        try load(pdfs: pdfs)
    }
}

// MARK: - Run

extension PDFGadget {
    /// Runs the batch job using supplied settings. (Load PDFs, run operations, and save PDFs)
    public func run(using settings: Settings) throws {
        logger.info("Processing...")
        
        do {
            try load(pdfs: settings.sourcePDFs, removeExisting: true)
            try perform(operations: settings.operations)
            if settings.savePDFs {
                try savePDFs(outputDir: settings.outputDir)
            }
        } catch {
            throw PDFGadgetError.runtimeError(
                "Failed to export: \(error.localizedDescription)"
            )
        }
        
        logger.info("Done.")
    }
    
    /// Load PDFs from disk.
    ///
    /// - Parameters:
    ///   - urls: File URLs for PDFS to load from disk.
    ///   - removeExisting: Remove currently loaded PDFs first.
    public func load(pdfs urls: [URL], removeExisting: Bool = false) throws {
        let docs = try urls.map {
            guard let doc = PDFDocument(url: $0) else {
                throw PDFGadgetError.runtimeError(
                    "Failed to read PDF file contents: \($0.path.quoted)"
                )
            }
            return doc
        }
        try load(pdfs: docs, removeExisting: removeExisting)
    }
    
    public func load(pdfs docs: [PDFDocument], removeExisting: Bool = false) throws {
        if removeExisting {
            pdfs = []
        }
        for doc in docs {
            pdfs.append(PDFFile(doc: doc))
        }
    }
    
    /// Perform one or more operations on the loaded PDFs.
    ///
    /// - Parameters:
    ///   - operations: One or more sequential operations to perform on the loaded PDF(s).
    public func perform(operations: [PDFOperation]) throws {
        for operation in operations {
            let result = try perform(operation: operation)
            
            switch result {
            case let .noChange(reason):
                if let reason {
                    logger.info("No change performed: \(reason)")
                } else {
                    logger.info("No change performed.")
                }
            case .changed:
                break
            }
        }
    }
    
    /// Save the PDFs to disk.
    ///
    /// - Parameters:
    ///   - outputDir: Output directory. Must be a folder that exists on disk.
    ///     If `nil`, PDF file(s) are saved to the same directory they exist.
    ///   - baseFilenames: Array of filenames (excluding .pdf file extension) to use.
    ///     If `nil`, a smart default is used.
    public func savePDFs(
        outputDir: URL?
    ) throws {
        let filenames = pdfs.map { $0.filenameForExport(withExtension: false) }
        
        // ensure there are exactly the right number of filenames
        guard filenames.count == pdfs.count else {
            throw PDFGadgetError.runtimeError(
                "Incorrect number of output filenames supplied."
            )
        }
        
        // ensure there are no duplicate filenames
        guard filenames.duplicateElements().isEmpty
        else {
            throw PDFGadgetError.runtimeError(
                "Output filenames are not unique."
            )
        }
        
        for (filename, pdf) in zip(filenames, pdfs) {
            let outFilePath = try formOutputFilePath(
                for: pdf,
                fileNameWithoutExtension: filename,
                outputDir: outputDir
            )
            
            // TODO: allow overwriting by way of Settings flag
            guard !outFilePath.fileExists else {
                throw PDFGadgetError.runtimeError(
                    "Output file already exists: \(outFilePath.path.quoted)"
                )
            }
            
            logger.info("Saving to file \(outFilePath.path.quoted)...")
            
            // PDFKit Obj-C header docs for `dataRepresentation(options:)`:
            //
            // "Methods to record the current state of the PDFDocument as data or a file.  Passing a QuartzFilter object
            // in the options dictionary with the key @"QuartzFilter" will allow you to have the filter applied when
            // saving the PDF."
            
            // PDFKit Obj-C header docs for `write(to:withOptions:)`:
            //
            // [This method] may take any CoreGraphics options that are typically  passed into CGPDFContextCreate(...)
            // and CGPDFContextCreateWithURL(...)'s auxiliaryInfo dictionary. For encryption, you may provide an owner
            // and user password via the keys PDFDocumentWriteOption, where the values should be non-zero length
            // strings.
            
            // TL;DR - write options can only be used with `.write(to:withOptions:)`
            
            if !pdf.doc.write(to: outFilePath, withOptions: pdf.writeOptions) {
                throw PDFGadgetError.runtimeError(
                    "An error occurred while attempting to save the PDF file."
                )
            }
        }
    }
}

// MARK: - Helpers

extension PDFGadget {
    /// Internal utility to execute a single operation.
    func perform(operation: PDFOperation) throws -> PDFOperationResult {
        logger.info("Performing operation: \(operation.verboseDescription)")
        
        switch operation {
        case .newFile:
            return try performNewFile()
            
        case let .cloneFile(file):
            return try performCloneFile(file: file)
            
        case let .filterFiles(files):
            return try performFilterFiles(files: files)
            
        case let .mergeFiles(files, target):
            return try performMergeFiles(files: files, appendingTo: target)
            
        case let .splitFile(file, discardUnused, splits):
            return try performSplitFile(file: file, discardUnused: discardUnused, splits: splits)
            
        case let .setFilename(file, filename):
            return try performSetFilename(file: file, filename: filename)
            
        case let .setFilenames(files, filenames):
            return try performSetFilenames(files: files, filenames: filenames)
            
        case let .removeFileAttributes(files):
            return try performRemoveFileAttributes(files: files)
            
        case let .setFileAttribute(files, attr, value):
            return try performSetFileAttribute(files: files, attribute: attr, value: value)
            
        case let .filterPages(file, filter):
            return try performFilterPages(file: file, pages: filter)
            
        case let .copyPages(fromFile, fromPages, toFile, toPageIndex):
            return try performInsertPages(
                from: fromFile,
                fromPages: fromPages,
                to: toFile,
                toPageIndex: toPageIndex,
                behavior: .copy
            )
            
        case let .movePages(fromFile, fromPages, toFile, toPageIndex):
            return try performInsertPages(
                from: fromFile,
                fromPages: fromPages,
                to: toFile,
                toPageIndex: toPageIndex,
                behavior: .move
            )
            
        case let .replacePages(fromFile, fromPages, toFile, toPages, behavior):
            return try performReplacePages(
                from: fromFile,
                fromPages: fromPages,
                to: toFile,
                toPages: toPages,
                behavior: behavior
            )
            
        case let .reversePageOrder(file, pages):
            return try performReversePageOrder(file: file, pages: pages)
            
        case let .rotatePages(files, pages, rotation):
            return try performRotatePages(files: files, pages: pages, rotation: rotation)
            
        case let .cropPages(files, pages, area, process):
            return try performCropPages(files: files, pages: pages, area: area, process: process)
            
        case let .filterAnnotations(files, pages, annotations):
            return try performFilterAnnotations(files: files, pages: pages, annotations: annotations)
            
        case let .burnInAnnotations(files):
            guard #available(macOS 13.0, *) else {
                throw PDFGadgetError.runtimeError("Burn in annotations is not supported. macOS 13 or higher is required.")
            }
            return try performBurnInAnnotations(files: files)
            
        case let .extractPlainText(file, pages, destination, pageBreak):
            return try performExtractPlainText(
                file: file,
                pages: pages,
                to: destination,
                pageBreak: pageBreak
            )
            
        case let .removeProtections(files):
            return try performRemoveProtections(files: files)
        }
    }
    
    /// Generates full output path including filename.
    func formOutputFilePath(
        for pdf: PDFFile,
        fileNameWithoutExtension: String,
        outputDir: URL?
    ) throws -> URL {
        var folderPath = outputDir
            ?? pdf.doc.documentURL?.deletingLastPathComponent()
        
        #if os(macOS)
        folderPath = folderPath ?? URL.desktopDirectoryBackCompat
        #endif
        
        guard let folderPath,
              folderPath.fileExists,
              folderPath.isFolder == true
        else {
            throw PDFGadgetError.runtimeError(
                "Could not determine output path. Output path is either not a folder or does not exist."
            )
        }
        
        return folderPath
            .appendingPathComponent(fileNameWithoutExtension)
            .appendingPathExtension("pdf")
    }
}

#endif
