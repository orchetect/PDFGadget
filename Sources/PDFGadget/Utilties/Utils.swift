//
//  Utils.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
internal import SwiftExtensions

extension RangeExpression where Bound: Strideable {
    @_disfavoredOverload
    func isContainedWithin(values: [Bound]) -> Bool {
        let bounds = getAbsoluteBounds()
        
        if let min = bounds.min, let max = bounds.max { // X...X, X..<X
            let lowerInclusive = values.contains(where: { $0 <= min })
            let upperInclusive = values.contains(where: { $0 >= max })
            return lowerInclusive && upperInclusive
        } else if let min = bounds.min { // X...
            return values.contains(where: { $0 >= min })
        } else if let max = bounds.max { // ...X, ..<X
            return values.contains(where: { $0 >= max })
        } else {
            return true
        }
    }
}

extension URL {
    @available(macOS 10.12, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    static var desktopDirectoryBackCompat: URL {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            return .desktopDirectory
        } else {
            return FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Desktop")
        }
    }
}

extension CGRect {
    /// Rotates the rect within its parent area, redefining the origin
    ///
    /// - Parameters:
    ///   - area: Parent area.
    ///   - isAbsolute: If `true`, this asserts that `self` and parent `area` share the same origin.
    ///     If `false`, the calculation is treated as relative (the parent's area is treated as
    ///     having a zero origin).
    /// - Returns: The rotated rect.
    func rotate90Degrees(
        within area: CGRect,
        isAbsolute: Bool
    ) -> Self {
        var rect = CGRect(
            x: origin.y,
            y: area.origin.y + area.width - width - (origin.x - area.origin.x),
            width: height,
            height: width
        )
        
        if !isAbsolute {
            rect.origin.x += area.origin.y
            rect.origin.y -= area.origin.x
        }
        
        return rect
    }
}
