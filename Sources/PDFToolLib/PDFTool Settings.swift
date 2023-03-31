//
//  PDFTool Settings.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import AppKit
import Foundation
import OTCore

extension PDFTool {
    public struct Settings {
        public enum Defaults {
            public static let operations: [PDFOperation] = []
            public static let outputBaseFileNamesWithoutExtension: [String]? = nil
            public static let outputDir: URL? = nil
        }
        
        public enum Validation {
            // public static let ... = 1 ... 10
        }
        
        public var sourcePDFs: [URL]
        public var outputDir: URL?
        public var operations: [PDFOperation]
        public var outputBaseFileNamesWithoutExtension: [String]?
        
        /// Initialize with defaults for default-able parameters.
        public init(
            sourcePDFs: [URL]
        ) throws {
            self.sourcePDFs = sourcePDFs
            
            self.outputDir = Defaults.outputDir
            self.operations = Defaults.operations
            self.outputBaseFileNamesWithoutExtension = Defaults.outputBaseFileNamesWithoutExtension
            
            try validate()
        }
        
        public init(
            sourcePDFs: [URL],
            outputDir: URL?,
            operations: [PDFOperation],
            outputBaseFileNamesWithoutExtension: [String]?
        ) throws {
            self.operations = operations
            self.sourcePDFs = sourcePDFs
            self.outputDir = outputDir
            self.outputBaseFileNamesWithoutExtension = outputBaseFileNamesWithoutExtension
            
            try validate()
        }
        
        private func validate() throws {
            try sourcePDFs.forEach { url in
                guard url.fileExists, url.isFolder == false else {
                    throw PDFToolError.validationError(
                        "File does not exist at \(url.path.quoted)."
                    )
                }
            }
            
            if let outputDir {
                guard outputDir.fileExists else {
                    throw PDFToolError.validationError(
                        "Output folder does not exist at \(outputDir.path.quoted)."
                    )
                }
                guard outputDir.isFolder == true else {
                    throw PDFToolError.validationError(
                        "Output path is not a folder: \(outputDir.path.quoted)."
                    )
                }
            }
            
            guard !operations.isEmpty else {
                throw PDFToolError.validationError(
                    "No operation(s) are specified."
                )
            }
        }
    }
}
