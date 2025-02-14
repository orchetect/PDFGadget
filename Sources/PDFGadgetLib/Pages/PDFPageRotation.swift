//
//  PDFPageRotation.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

/// PDF editing page rotation descriptor.
public struct PDFPageRotation {
    public var angle: Angle
    public var process: PDFOperation.ChangeBehavior
    
    public init(angle: Angle, process: PDFOperation.ChangeBehavior = .relative) {
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

extension PDFPageRotation: Equatable { }

extension PDFPageRotation: Hashable { }

extension PDFPageRotation {
    public var verboseDescription: String {
        "\(process == .relative ? "by" : "to") \(angle.verboseDescription)"
    }
}

extension PDFPageRotation: Sendable { }

#endif
