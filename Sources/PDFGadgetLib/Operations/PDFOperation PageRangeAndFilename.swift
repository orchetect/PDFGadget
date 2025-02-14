//
//  PDFOperation PageRangeAndFilename.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

extension PDFOperation {
    /// PDF editing operation page range & filename descriptor.
    public struct PageRangeAndFilename {
        public var pageRange: ClosedRange<Int>
        public var filename: String?
        
        public init(_ pageRange: ClosedRange<Int>, _ filename: String? = nil) {
            self.pageRange = pageRange
            self.filename = filename
        }
    }
}

extension PDFOperation.PageRangeAndFilename: Equatable { }

extension PDFOperation.PageRangeAndFilename: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        // TODO: naïve sorting but mostly works, could be better
        lhs.pageRange.lowerBound < rhs.pageRange.lowerBound
    }
}

extension PDFOperation.PageRangeAndFilename: Hashable { }

extension PDFOperation.PageRangeAndFilename: Sendable { }

extension PDFOperation.PageRangeAndFilename {
    public var verboseDescription: String {
        if let filename {
            return "page range \(pageRange) with name \(filename.quoted)"
        } else {
            return "page range \(pageRange)"
        }
    }
}

#endif
