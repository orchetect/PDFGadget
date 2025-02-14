//
//  PDFPageInset.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

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

extension PDFPageInset: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .points(value):
            "\(value)"
        case let .scale(factor):
            "scale x(\(factor))"
        case .passthrough:
            "same"
        }
    }
}
