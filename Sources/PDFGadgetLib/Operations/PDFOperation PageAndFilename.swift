//
//  PDFOperation PageAndFilename.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

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

extension PDFOperation.PageAndFilename: Sendable { }

extension PDFOperation.PageAndFilename {
    public var verboseDescription: String {
        if let filename {
            return "page index \(pageIndex)  with name \(filename.quoted)"
        } else {
            return "page index \(pageIndex)"
        }
    }
}

#endif
