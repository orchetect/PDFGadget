//
//  PDFOperation ChangeBehavior.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

extension PDFOperation {
    /// PDF editing operation value modification behavior.
    public enum ChangeBehavior {
        /// Set absolute page rotation value, replacing existing rotation if any.
        case absolute
        
        /// Relative to current page rotation, if any.
        /// If current page rotation is 0 degrees, this is identical to ``absolute``.
        case relative
    }
}

extension PDFOperation.ChangeBehavior: Equatable { }

extension PDFOperation.ChangeBehavior: Hashable { }

extension PDFOperation.ChangeBehavior: Sendable { }

extension PDFOperation.ChangeBehavior {
    public var verboseDescription: String {
        switch self {
        case .absolute:
            return "absolute"
        case .relative:
            return "relative"
        }
    }
}

#endif
