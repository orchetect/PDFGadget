//
//  PDFFilesDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

/// Criteria to match an arbitrary number of PDF files.
public enum PDFFilesDescriptor {
    case all
    case first
    case second
    case last
    case index(Int)
    case indexes([Int])
    case indexRange(ClosedRange<Int>)
    case filename(PDFFilenameDescriptor)
    case introspecting(description: String,
                       _ closure: (_ pdf: PDFDocument) -> Bool)
}

extension PDFFilesDescriptor {
    public var verboseDescription: String {
        switch self {
        case .all:
            return "all files"
        case .first:
            return "first file"
        case .second:
            return "second file"
        case .last:
            return "last file"
        case .index(let idx):
            return "file with index \(idx)"
        case .indexes(let idxes):
            return "files with indexes \(idxes.map { String($0) }.joined(separator: ", "))"
        case .indexRange(let range):
            return "files with index range \(range.lowerBound)-\(range.upperBound))"
        case .filename(_):
            return "file with filename criteria"
        case .introspecting(let description, _):
            return "file matching \(description)"
        }
    }
}
