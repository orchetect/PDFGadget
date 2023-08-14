//
//  Qualifier Types.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

extension PDFOperation {
    /// PDF editing operation behavior.
    public enum InterchangeBehavior: Equatable, Hashable {
        case copy
        case move
    }
}

extension PDFOperation.InterchangeBehavior {
    public var verboseDescription: String {
        switch self {
        case .copy:
            return "copying"
        case .move:
            return "moving"
        }
    }
}

extension PDFOperation {
    /// PDF editing operation value modification behavior.
    public enum ValueModification: Equatable, Hashable {
        /// Set absolute page rotation value, replacing existing rotation if any.
        case absolute
        
        /// Relative to current page rotation, if any.
        /// If current page rotation is 0 degrees, this is identical to ``absolute``.
        case relative
    }
}

extension PDFOperation.ValueModification {
    public var verboseDescription: String {
        switch self {
        case .absolute:
            return "absolute"
        case .relative:
            return "relative"
        }
    }
}

extension PDFOperation {
    /// PDF editing operation page & filename descriptor.
    public struct PageAndFilename: Equatable, Hashable {
        public var pageIndex: Int
        public var filename: String?
        
        public init(_ pageIndex: Int, _ filename: String? = nil) {
            self.pageIndex = pageIndex
            self.filename = filename
        }
    }
}

extension PDFOperation.PageAndFilename: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.pageIndex < rhs.pageIndex
    }
}

extension PDFOperation.PageAndFilename {
    public var verboseDescription: String {
        if let filename {
            return "page index \(pageIndex)  with name \(filename.quoted)"
        } else {
            return "page index \(pageIndex)"
        }
    }
}

extension PDFOperation {
    /// PDF editing operation page range & filename descriptor.
    public struct PageRangeAndFilename: Equatable, Hashable {
        public var pageRange: ClosedRange<Int>
        public var filename: String?
        
        public init(_ pageRange: ClosedRange<Int>, _ filename: String? = nil) {
            self.pageRange = pageRange
            self.filename = filename
        }
    }
}

extension PDFOperation.PageRangeAndFilename: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        // TODO: naïve sorting but mostly works, could be better
        lhs.pageRange.lowerBound < rhs.pageRange.lowerBound
    }
}

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
