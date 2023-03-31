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
    let settings: Settings
    
    var pdfs: [PDFDocument] = []
    
    init(settings: Settings) {
        self.settings = settings
    }
}

// MARK: - Run

extension PDFTool {
    public static func process(settings: Settings) throws {
        try self.init(settings: settings).run()
    }
    
    func run() throws {
        logger.info("Processing...")
        
        do {
            try loadInputPDFs()
            try performOperations()
            try saveOutputPDFs()
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
    func loadInputPDFs() throws {
        pdfs = []
        for url in settings.sourcePDFs {
            guard let doc = PDFDocument(url: url) else {
                throw PDFToolError.runtimeError(
                    "Failed to read PDF file contents: \(url.path.quoted)"
                )
            }
            pdfs.append(doc)
        }
    }
    
    func performOperations() throws {
        for operation in settings.operations {
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
    
    func perform(operation: PDFOperation) throws -> PDFOperationResult {
        logger.info("Performing operation: \(operation.verboseDescription)")
        
        switch operation {
        case let .filterFiles(files):
            return try performFilterFiles(files: files)
            
        case let .filterPages(file, filter):
            return try performFilterPages(file: file, pages: filter)
            
        case let .reversePageOrder(file):
            return try performReversePageOrder(file: file)
            
        case let .replacePages(fromFile, fromPages, toFile, toPages):
            return try performReplacePages(
                from: fromFile,
                fromPages: fromPages,
                to: toFile,
                toPages: toPages
            )
            
        case let .rotate(file, pages, rotation):
            return try performRotatePages(file: file, pages: pages, rotation: rotation)
            
        case let .filterAnnotations(file, pages, annotations):
            return try performFilterAnnotations(file: file, pages: pages, annotations: annotations)
        }
    }
    
    func saveOutputPDFs() throws {
        let filenames = settings.outputBaseFileNamesWithoutExtension
            ?? pdfs.map { $0.filenameWithoutExtension?.appending("-processed") ?? "File" }
        
        // ensure there are exactly the right number of filenames
        guard filenames.count == pdfs.count else {
            throw PDFToolError.runtimeError(
                "Failed to prepare output filenames."
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
            let outFilePath = try formOutputFilePath(for: pdf, fileNameWithoutExtension: filename)
            
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
    /// Used when output path is not specified.
    /// Generates output path based on input path.
    private func formOutputFilePath(
        for pdf: PDFDocument,
        fileNameWithoutExtension: String
    ) throws -> URL {
        guard let folderPath = settings.outputDir
                ?? pdf.documentURL?.deletingLastPathComponent()
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
