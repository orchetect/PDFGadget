//
//  PDFTool.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import AppKit
import Logging
import OTCore

public final class PDFTool {
    private let logger = Logger(label: "\(PDFTool.self)")
    private let settings: Settings
    
    init(settings: Settings) {
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
            #warning("> do stuff")
        } catch {
            throw PDFToolError.runtimeError(
                "Failed to export: \(error.localizedDescription)"
            )
        }
        
        logger.info("Done.")
    }
}

extension PDFTool {
    /// Used when output path is not specified.
    /// Generates output path based on input path.
    private func makeDefaultOutputPath(from firstSourceFile: URL) throws -> URL {
        firstSourceFile.deletingLastPathComponent()
    }
    
    // private func nowTimestamp() -> String {
    //    let now = Date()
    //    let formatter = DateFormatter()
    //    formatter.dateFormat = "yyyy-MM-dd hh-mm-ss"
    //    return formatter.string(from: now)
    // }
}
