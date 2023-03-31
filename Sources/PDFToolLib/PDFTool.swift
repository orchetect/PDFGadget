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
                    print("No change performed: \(reason)")
                } else {
                    print("No change performed.")
                }
            case .changed:
                break
            }
        }
    }
    
    func perform(operation: PDFOperation) throws -> PDFOperationResult {
        logger.info("Performing operation: \(operation.verboseDescription)")
        
        switch operation {
        case let .filterPages(file, filter):
            return try performFilterPages(file: file, filter: filter)
            
        case let .reversePageOrder(file):
            return try performReversePageOrder(file: file)
            
        case let .replacePages(fromFileIndex, fromFilter, toFileIndex, toFilter):
            return try performReplacePages(
                fromFileIndex: fromFileIndex,
                fromFilter: fromFilter,
                toFileIndex: toFileIndex,
                toFilter: toFilter
            )
            
        case let .rotate(fileIndex, pages, rotation):
            return try performRotatePages(file: fileIndex, filter: pages, rotation: rotation)
            
        case let .removeAnnotations(fileIndex, pages):
            return try performRemoveAnnotations(file: fileIndex, filter: pages)
        }
    }
    
    func saveOutputPDFs() throws {
        // TODO: this may need refactoring in future if some operations cause multiple output PDF files
        let pdf = try expectOneFile(
            index: 0,
            error: "Encountered more than one PDF while attempting to export. This is an error condition."
        )
                
        let outFilePath = try getOutputFilePath(from: settings)
        
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

// MARK: - Helpers

extension PDFTool {
    /// Used when output path is not specified.
    /// Generates output path based on input path.
    private func getOutputFilePath(
        from settings: Settings,
        fileNameWithoutExtension: String? = nil
    ) throws -> URL {
        guard let folderPath = settings.outputDir
            ?? settings.sourcePDFs.first?.deletingLastPathComponent()
        else {
            throw PDFToolError.runtimeError(
                "Could not determine output path. Output path is either not a folder or does not exist."
            )
        }
        
        let baseFileName = fileNameWithoutExtension
            ?? settings.sourcePDFs.first?.deletingPathExtension().lastPathComponent
            .appending("-processed")
            ?? "Processed"
        
        return folderPath
            .appendingPathComponent(baseFileName)
            .appendingPathExtension("pdf")
    }
}
