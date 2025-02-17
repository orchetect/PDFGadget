//
//  PDFPageInset.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

public enum PDFPageInset {
    /// A literal value in points.
    case points(Double)
    
    /// A scale factor.
    /// `1.0` represents 1:1 scale to original.
    case scale(factor: Double)
    
    /// Preserve the inset as-is, unchanged.
    case passthrough
}

extension PDFPageInset: Equatable { }

extension PDFPageInset: Hashable { }

extension PDFPageInset: Sendable { }

extension PDFPageInset {
    public var verboseDescription: String {
        switch self {
        case let .points(value):
            "\(value)pts"
        case let .scale(factor):
            "scaled \(factor)x"
        case .passthrough:
            "same"
        }
    }
}

// MARK: - Utilities

extension PDFPageInset {
    static func rotate(
        top: PDFPageInset,
        leading: PDFPageInset,
        bottom: PDFPageInset,
        trailing: PDFPageInset,
        by rotation: PDFPageRotation.Angle
    ) -> (
        top: PDFPageInset,
        leading: PDFPageInset,
        bottom: PDFPageInset,
        trailing: PDFPageInset
    ) {
        switch rotation {
        case ._0degrees:
            (top, leading, bottom, trailing)
        case ._90degrees:
            (trailing, top, leading, bottom)
        case ._180degrees:
            (bottom, trailing, top, leading)
        case ._270degrees:
            (leading, bottom, trailing, top)
        }
    }
}

#endif
