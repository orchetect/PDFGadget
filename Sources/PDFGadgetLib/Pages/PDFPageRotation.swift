//
//  PDFPageRotation.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation

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

// MARK: - Angle

extension PDFPageRotation {
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

extension PDFPageRotation.Angle {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self.init(degrees: lhs.degrees + rhs.degrees) ?? ._0degrees
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self.init(degrees: lhs.degrees - rhs.degrees) ?? ._0degrees
    }
}
