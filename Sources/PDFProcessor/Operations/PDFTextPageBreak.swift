//
//  PDFTextPageBreak.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

/// Character(s) to insert at PDF page breaks in plain text output.
public enum PDFTextPageBreak: String {
    case none = ""
    case newLine = "\n"
    case doubleNewLine = "\n\n"
}

extension PDFTextPageBreak: Equatable { }

extension PDFTextPageBreak: Hashable { }

extension PDFTextPageBreak: Sendable { }

extension PDFTextPageBreak {
    public var verboseDescription: String {
        switch self {
        case .none:
            return "none"
        case .newLine:
            return "new-line"
        case .doubleNewLine:
            return "double new-line"
        }
    }
}

#endif
