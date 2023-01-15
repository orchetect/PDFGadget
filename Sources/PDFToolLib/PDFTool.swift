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
    
    public init(settings: Settings) {
        self.settings = settings
    }
}

// MARK: - Run

extension PDFTool {
    public static func process(_ settings: Settings) throws {
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
            case .noChange(let reason):
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
        case .filterPages(let filter):
            return try performFilterPages(filter: filter)
            
        case .reversePageOrder:
            return try performReversePageOrder()
            
        case .replacePages(let fromFile1, let toFile2):
            return try performReplacePages(fromFile1: fromFile1, toFile2: toFile2)
        }
    }
    
    func saveOutputPDFs() throws {
        #warning("> not done yet")
    }
}

// MARK: - Helpers

extension PDFTool {
    /// Used when output path is not specified.
    /// Generates output path based on input path.
    private func makeDefaultOutputPath(from firstSourceFile: URL) throws -> URL {
        firstSourceFile.deletingLastPathComponent()
    }
}
