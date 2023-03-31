//
//  PDFTool.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import AppKit
import Logging
import OTCore
import PDFKit

public final class PDFTool {
    let logger = Logger(label: "\(PDFTool.self)")
    
    public var pdfs: [PDFDocument] = []
    
    public init() { }
    
    public init(pdfs: [PDFDocument]) {
        self.pdfs = pdfs
    }
    
    public init(pdfs: [URL]) throws {
        try load(pdfs: pdfs)
    }
}

// MARK: - Run

extension PDFTool {
    /// Runs the batch job using supplied settings. (Load PDFs, run operations, and save PDFs)
    public func run(using settings: Settings) throws {
        logger.info("Processing...")
        
        do {
            try load(pdfs: settings.sourcePDFs, removeExisting: true)
            try perform(operations: settings.operations)
            if settings.savePDFs {
                try self.savePDFs(
                    outputDir: settings.outputDir,
                    baseFilenames: settings.outputBaseFilenamesWithoutExtension
                )
            }
        } catch {
            throw PDFToolError.runtimeError(
                "Failed to export: \(error.localizedDescription)"
            )
        }
        
        logger.info("Done.")
    }
}

// MARK: - Operations

extension PDFTool {
    /// Load PDFs from disk.
    public func load(pdfs urls: [URL], removeExisting: Bool = false) throws {
        if removeExisting {
            pdfs = []
        }
        for url in urls {
            guard let doc = PDFDocument(url: url) else {
                throw PDFToolError.runtimeError(
                    "Failed to read PDF file contents: \(url.path.quoted)"
                )
            }
            pdfs.append(doc)
        }
    }
    
    /// Perform one or more operations on the loaded PDFs.
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
    
    /// Internal utility to execute a single operation.
    func perform(operation: PDFOperation) throws -> PDFOperationResult {
        logger.info("Performing operation: \(operation.verboseDescription)")
        
        switch operation {
        case let .cloneFile(file):
            return try performCloneFile(file: file)
            
        case let .filterFiles(files):
            return try performFilterFiles(files: files)
            
        case let .mergeFiles(files, target):
            return try performMergeFiles(files: files, appendingTo: target)
            
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
            
        case let .reversePageOrder(file):
            return try performReversePageOrder(file: file)
            
        case let .replacePages(fromFile, fromPages, toFile, toPages, behavior):
            return try performReplacePages(
                from: fromFile,
                fromPages: fromPages,
                to: toFile,
                toPages: toPages,
                behavior: behavior
            )
            
        case let .rotate(file, pages, rotation):
            return try performRotatePages(file: file, pages: pages, rotation: rotation)
            
        case let .filterAnnotations(file, pages, annotations):
            return try performFilterAnnotations(file: file, pages: pages, annotations: annotations)
        }
    }
    
    /// Save the PDFs to disk.
    /// - Parameters:
    ///   - outputDir: Output directory. Must be a folder that exists on disk.
    ///     If `nil`, PDF file(s) are saved to the same directory they exist.
    ///   - baseFilenames: Array of filenames (excluding .pdf file extension) to use.
    ///     If `nil`, the current filename with a '-processed' suffix is used.
    public func savePDFs(
        outputDir: URL?,
        baseFilenames: [String]?
    ) throws {
        let filenames = baseFilenames
            ?? pdfs.map { $0.filenameWithoutExtension?.appending("-processed") ?? "File" }
        
        // ensure there are exactly the right number of filenames
        guard filenames.count == pdfs.count else {
            throw PDFToolError.runtimeError(
                "Incorrect number of output filenames supplied."
            )
        }
        
        // ensure there are no duplicate filenames
        guard Set(filenames.map({ $0.lowercased() })).count
                == filenames.map({ $0.lowercased() }).count
        else {
            throw PDFToolError.runtimeError(
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
                throw PDFToolError.runtimeError(
                    "Output file already exists: \(outFilePath.path.quoted)"
                )
            }
            
            logger.info("Saving to file \(outFilePath.path.quoted)...")
            if !pdf.write(to: outFilePath) {
                throw PDFToolError.runtimeError(
                    "An error occurred while attempting to save the PDF file."
                )
            }
        }
    }
}

// MARK: - Helpers

extension PDFTool {
    /// Generates full output path including filename.
    private func formOutputFilePath(
        for pdf: PDFDocument,
        fileNameWithoutExtension: String,
        outputDir: URL?
    ) throws -> URL {
        let folderPath = outputDir
            ?? pdf.documentURL?.deletingLastPathComponent()
            ?? URL.desktopDirectoryBackCompat
        
        guard folderPath.fileExists,
            folderPath.isFolder == true
        else {
            throw PDFToolError.runtimeError(
                "Could not determine output path. Output path is either not a folder or does not exist."
            )
        }
        
        return folderPath
            .appendingPathComponent(fileNameWithoutExtension)
            .appendingPathExtension("pdf")
    }
}
