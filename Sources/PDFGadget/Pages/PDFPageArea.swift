//
//  PDFPageArea.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
internal import SwiftExtensions

public enum PDFPageArea {
    /// Literal inset values.
    /// A value of zero represents no change.
    case insets(
        top: PDFPageInset = .passthrough,
        leading: PDFPageInset = .passthrough,
        bottom: PDFPageInset = .passthrough,
        trailing: PDFPageInset = .passthrough
    )
    
    /// Literal bounds values in points.
    case rect(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    )
}

extension PDFPageArea: Equatable { }

extension PDFPageArea: Hashable { }

extension PDFPageArea: Sendable { }

extension PDFPageArea {
    public var verboseDescription: String {
        switch self {
        case let .insets(top, leading, bottom, trailing):
            return "insets top: \(top.verboseDescription), leading: \(leading.verboseDescription), bottom: \(bottom.verboseDescription), trailing: \(trailing.verboseDescription)"
        case let .rect(x, y, width, height):
            return "area x:\(x) y:\(y) w:\(width) h:\(height)"
        }
    }
}

// MARK: - Static Constructors

extension PDFPageArea {
    /// Scale the bounds by a uniform scale factor.
    /// `1.0` represents 1:1 scale to original.
    public static func scale(factor: Double) -> Self {
        .insets(
            top: .scale(factor: factor),
            leading: .scale(factor: factor),
            bottom: .scale(factor: factor),
            trailing: .scale(factor: factor)
        )
    }
    
    #if os(macOS)
    public static func insets(_ insets: NSEdgeInsets) -> Self {
        .insets(
            top: .points(insets.top),
            leading: .points(insets.left),
            bottom: .points(insets.bottom),
            trailing: .points(insets.right)
        )
    }
    #endif
    
    public static func rect(_ rect: CGRect) -> Self {
        .rect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension PDFPageArea {
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func insets(_ insets: EdgeInsets) -> Self {
        .insets(
            top: .points(insets.top),
            leading: .points(insets.leading),
            bottom: .points(insets.bottom),
            trailing: .points(insets.trailing)
        )
    }
}
#endif

// MARK: - Methods

extension PDFPageArea {
    public func rect(
        for source: CGRect,
        rotation: PDFPageRotation.Angle = ._0degrees
    ) -> CGRect {
        switch self {
        case let .insets(top, leading, bottom, trailing):
            let (top, leading, bottom, trailing) = PDFPageInset.rotate(
                top: top,
                leading: leading,
                bottom: bottom,
                trailing: trailing,
                by: rotation
            )
            
            var x = source.origin.x
            var y = source.origin.y
            var width = source.width
            var height = source.height
            
            switch top {
            case let .points(value):
                height += value
            case var .scale(factor):
                factor = factor.clamped(to: 0.01 ... 100.0)
                height *= factor
            case .passthrough:
                break
            }
            
            switch leading {
            case let .points(value):
                width += value
                x -= value
            case var .scale(factor):
                factor = factor.clamped(to: 0.01 ... 100.0)
                width *= factor
                x += (source.width - (source.width * factor))
            case .passthrough:
                break
            }
            
            switch bottom {
            case let .points(value):
                height += value
                y -= value
            case var .scale(factor):
                factor = factor.clamped(to: 0.01 ... 100.0)
                height *= factor
                y += (source.height - (source.height * factor))
            case .passthrough:
                break
            }
            
            switch trailing {
            case let .points(value):
                width += value
            case var .scale(factor):
                factor = factor.clamped(to: 0.01 ... 100.0)
                width *= factor
            case .passthrough:
                break
            }
            
            // TODO: Add additional guards for validation checks to prevent inversions
            
            return CGRect(x: x, y: y, width: width, height: height)
            
        case let .rect(x, y, width, height):
            // associated values define a rect in the current rotation presentation,
            // however PDFKit treats bounds in the page's non-rotated coordinate context.
            // this means we need to "rotate" our coordinates respectively to convert them
            // if the page is rotated.
            
            switch rotation {
            case ._0degrees:
                var rect = CGRect(x: x, y: y, width: width, height: height)
                rect.origin.x += source.origin.x
                rect.origin.y += source.origin.y
                return rect
            case ._90degrees:
                var rect = CGRect(x: x, y: y, width: width, height: height)
                
                var source = source.rotate90Degrees(within: source, isAbsolute: true)
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                source = source.rotate90Degrees(within: source, isAbsolute: true)
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                source = source.rotate90Degrees(within: source, isAbsolute: true)
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                return rect
            case ._180degrees:
                var rect = CGRect(x: x, y: y, width: width, height: height)
                
                var source = source
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                source = source.rotate90Degrees(within: source, isAbsolute: true)
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                return rect
            case ._270degrees:
                var rect = CGRect(x: x, y: y, width: width, height: height)
                
                let source = source.rotate90Degrees(within: source, isAbsolute: true)
                rect = rect.rotate90Degrees(within: source, isAbsolute: false)
                
                return rect
            }
        }
    }
}

#endif
