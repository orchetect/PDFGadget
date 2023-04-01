//
//  Qualifier Types.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

extension PDFOperation {
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
    public struct PageAndFilename: Equatable, Hashable {
        public var pageIndex: Int
        public var filename: String?
        
        public init(_ pageIndex: Int, _ filename: String? = nil) {
            self.pageIndex = pageIndex
            self.filename = filename
        }
    }
}

extension PDFOperation.PageAndFilename {
    public var verboseDescription: String {
        if let filename {
            return "page index \(pageIndex) to \(filename.quoted)"
        } else {
            return "page index \(pageIndex)"
        }
    }
}
