//
//  PDFGadget Settings.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
/* private */ import OTCore

extension PDFGadget {
    public struct Settings {
        public enum Defaults {
            public static let operations: [PDFOperation] = []
            public static let outputDir: URL? = nil
            public static let savePDFs: Bool = true
        }
        
        public enum Validation {
            // public static let ... = 1 ... 10
        }
        
        public var sourcePDFs: [URL]
        public var outputDir: URL?
        public var operations: [PDFOperation]
        public var savePDFs: Bool
        
        /// Initialize with defaults for default-able parameters.
        public init(
            sourcePDFs: [URL]
        ) throws {
            self.sourcePDFs = sourcePDFs
            
            self.outputDir = Defaults.outputDir
            self.operations = Defaults.operations
            self.savePDFs = Defaults.savePDFs
            
            try validate()
        }
        
        public init(
            sourcePDFs: [URL],
            outputDir: URL?,
            operations: [PDFOperation],
            savePDFs: Bool
        ) throws {
            self.operations = operations
            self.sourcePDFs = sourcePDFs
            self.outputDir = outputDir
            self.savePDFs = savePDFs
            
            try validate()
        }
        
        private func validate() throws {
            try sourcePDFs.forEach { url in
                guard url.fileExists, url.isFolder == false else {
                    throw PDFGadgetError.validationError(
                        "File does not exist at \(url.path.quoted)."
                    )
                }
            }
            
            if let outputDir {
                guard outputDir.fileExists else {
                    throw PDFGadgetError.validationError(
                        "Output folder does not exist at \(outputDir.path.quoted)."
                    )
                }
                guard outputDir.isFolder == true else {
                    throw PDFGadgetError.validationError(
                        "Output path is not a folder: \(outputDir.path.quoted)."
                    )
                }
            }
            
            guard !operations.isEmpty else {
                throw PDFGadgetError.validationError(
                    "No operation(s) are specified."
                )
            }
        }
    }
}

#endif
