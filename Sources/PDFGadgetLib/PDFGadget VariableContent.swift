//
//  PDFGadget VariableContent.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
@preconcurrency import PDFKit

extension PDFGadget {
    public enum VariableContent {
        /// Plain text content.
        case string(String)
        
        /// Reference to a PDF page.
        case pdfPage(PDFPage)
        
        /// Reference to a PDF document.
        case pdfDocument(PDFDocument)
    }
}

extension PDFGadget.VariableContent: Sendable { }

#endif
