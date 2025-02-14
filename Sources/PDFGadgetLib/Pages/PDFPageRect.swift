//
//  PDFPageRect.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
internal import OTCore

public enum PDFPageRect {
    /// Scale the bounds by a uniform scale factor.
    /// `1.0` represents 1:1 scale to original.
    case scale(factor: Double)
    
    /// Scale insets individually by their own scale factor.
    /// `1.0` represents 1:1 scale to original.
    case scaleInsets(
        top: Double = 1.0,
        leading: Double = 1.0,
        bottom: Double = 1.0,
        trailing: Double = 1.0
    )
    
    /// Literal bounds values.
    case rect(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    )
}

extension PDFPageRect: Equatable { }

extension PDFPageRect: Hashable { }

extension PDFPageRect: Sendable { }

// MARK: - Static Constructors

extension PDFPageRect {
    #if os(macOS)
    public static func scaleInsets(_ insets: NSEdgeInsets) -> Self {
        .scaleInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right
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

extension PDFPageRect {
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func scaleInsets(_ insets: EdgeInsets) -> Self {
        .scaleInsets(
            top: insets.top,
            leading: insets.leading,
            bottom: insets.bottom,
            trailing: insets.trailing
        )
    }
}
#endif

extension PDFPageRect {
    public func rect(for source: CGRect) -> CGRect {
        switch self {
        case let .scale(factor):
            let factor = factor.clamped(to: 0.01 ... 100.0)
            return source.scale(factor: factor)
            
        case let .scaleInsets(top, leading, bottom, trailing):
            let top = top.clamped(to: 0.01 ... 100.0)
            let leading = leading.clamped(to: 0.01 ... 100.0)
            let bottom = bottom.clamped(to: 0.01 ... 100.0)
            let trailing = trailing.clamped(to: 0.01 ... 100.0)
            
            // TODO: Add additional guards for validation checks to prevent inversions
            
            let width = source.width * leading * trailing
            let height = source.height * top * bottom
            let x = source.origin.x
                + (source.width - (source.width * leading))
            let y = source.origin.y
                + (source.height - (source.height * bottom))
            
            return CGRect(x: x, y: y, width: width, height: height)
            
        case let .rect(x, y, width, height):
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

extension PDFPageRect {
    public var verboseDescription: String {
        switch self {
        case let .scale(factor):
            return "scale factor of \(factor)"
        case let .scaleInsets(top, leading, bottom, trailing):
            return "scale insets top:\(top) leading:\(leading) bottom:\(bottom) trailing:\(trailing)"
        case let .rect(x, y, width, height):
            return "area x:\(x) y:\(y) w:\(width) h:\(height)"
        }
    }
}
