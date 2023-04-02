//
//  Utils.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore

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
