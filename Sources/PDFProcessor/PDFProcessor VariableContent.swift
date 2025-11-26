//
//  PDFProcessor VariableContent.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
@preconcurrency import PDFKit

extension PDFProcessor {
    public enum VariableContent {
        /// Plain text content.
        case string(String)
        
        /// Reference to a PDF page.
        case pdfPage(PDFPage)
        
        /// Reference to a PDF document.
        case pdfDocument(PDFDocument)
    }
}

extension PDFProcessor.VariableContent: Equatable { }

extension PDFProcessor.VariableContent: Hashable { }

extension PDFProcessor.VariableContent: Sendable { }

#endif
