//
//  PDFPageRotation.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

/// PDF editing page rotation descriptor.
public struct PDFPageRotation: Equatable, Hashable {
    public var angle: Angle
    public var process: PDFOperation.ValueModification
    
    public init(angle: Angle, process: PDFOperation.ValueModification = .relative) {
        self.angle = angle
        self.process = process
    }
    
    public func degrees(offsetting other: Angle = ._0degrees) -> Int {
        switch process {
        case .absolute: return angle.degrees
        case .relative: return (angle + other).degrees
        }
    }
}

extension PDFPageRotation: CustomStringConvertible {
    public var description: String {
        "\(process == .relative ? "by" : "to") \(angle)"
    }
}

extension PDFPageRotation: Sendable { }

// MARK: - Angle

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
        
        public var degrees: Int {
            rawValue
        }
    }
}

extension PDFPageRotation.Angle: CustomStringConvertible {
    public var description: String {
        "\(rawValue) degrees"
    }
}

extension PDFPageRotation.Angle: Sendable { }

extension PDFPageRotation.Angle {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(degrees: lhs.degrees + rhs.degrees) ?? ._0degrees
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(degrees: lhs.degrees - rhs.degrees) ?? ._0degrees
    }
}

#endif
