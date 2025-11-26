//
//  PDFOperation InterchangeBehavior.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

extension PDFOperation {
    /// PDF editing operation behavior.
    public enum InterchangeBehavior {
        case copy
        case move
    }
}

extension PDFOperation.InterchangeBehavior: Equatable { }

extension PDFOperation.InterchangeBehavior: Hashable { }

extension PDFOperation.InterchangeBehavior: Sendable { }

extension PDFOperation.InterchangeBehavior {
    public var verboseDescription: String {
        switch self {
        case .copy:
            return "copying"
        case .move:
            return "moving"
        }
    }
}

#endif
