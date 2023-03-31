//
//  Utils.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

extension RangeExpression where Bound: Strideable {
    public func isContainedWithin(values: [Bound]) -> Bool {
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
