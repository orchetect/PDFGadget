//
//  PDFPageRect.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation

public enum PDFPageRect: Equatable, Hashable {
    case scale(factor: Double)
    
    case scaleInsets(
        top: Double = 1.0,
        leading: Double = 1.0,
        bottom: Double = 1.0,
        trailing: Double = 1.0
    )
    
    case rect(
        x: Double = 0.0,
        y: Double = 0.0,
        width: Double = 1.0,
        height: Double = 1.0
    )
}

// MARK: - Static Constructors

extension PDFPageRect {
    public static func scaleInsets(_ insets: NSEdgeInsets) -> Self {
        .scaleInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
    }
    
    public static func rect(_ rect: CGRect) -> Self {
        .rect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension PDFPageRect {
    @available(macOS 10.15, *)
    public static func scaleInsets(_ insets: EdgeInsets) -> Self {
        .scaleInsets(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing)
    }
}
#endif

extension PDFPageRect {
    public func rect(for source: CGRect) -> CGRect {
        switch self {
        case .scale(let factor):
            let factor = factor.clamped(to: 0.01 ... 100.0)
            return source.scale(factor: factor)
            
        case .scaleInsets(let top, let leading, let bottom, let trailing):
            guard top > 0, leading > 0, bottom > 0, trailing > 0 else { return source }
            // TODO: Add additional guards for validation checks
            
            var rect = source
            
            rect.size.width = rect.width * leading * trailing
            rect.size.height = rect.height * top * bottom
            rect.origin.x = rect.origin.x + (rect.height - (rect.height * bottom))
            rect.origin.y = rect.origin.y + (rect.width - (rect.width * leading))
            
            return rect
            
        case .rect(let x, let y, let width, let height):
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

extension PDFPageRect {
    public var verboseDescription: String {
        switch self {
        case .scale(let factor):
            return "scale factor of \(factor)"
        case .scaleInsets(let top, let leading, let bottom, let trailing):
            return "scale insets \(top) \(leading) \(bottom) \(trailing)"
        case .rect(let x, let y, let width, let height):
            return "area x:\(x) y:\(y) w:\(width) h:\(height)"
        }
    }
}
