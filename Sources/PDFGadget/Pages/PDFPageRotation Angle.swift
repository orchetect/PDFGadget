//
//  PDFPageRotation Angle.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

extension PDFPageRotation {
    /// PDF editing page rotation angle.
    public enum Angle: Int {
        case _0degrees = 0
        case _90degrees = 90
        case _180degrees = 180
        case _270degrees = 270
        
        public init?(degrees: Int) {
            if degrees < 0 {
                self.init(rawValue: 360 + (degrees % 360))
            } else {
                self.init(rawValue: degrees % 360)
            }
        }
    }
}

extension PDFPageRotation.Angle: Equatable { }

extension PDFPageRotation.Angle: Hashable { }

extension PDFPageRotation.Angle {
    public var verboseDescription: String {
        "\(rawValue) degrees"
    }
}

extension PDFPageRotation.Angle: Sendable { }

// MARK: - Properties

extension PDFPageRotation.Angle {
    public var degrees: Int {
        rawValue
    }
}

// MARK: - Operators

extension PDFPageRotation.Angle {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(degrees: lhs.degrees + rhs.degrees) ?? ._0degrees
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(degrees: lhs.degrees - rhs.degrees) ?? ._0degrees
    }
}

#endif
