//
//  PDFFileDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

/// Criteria to match a single PDF file.
public enum PDFFileDescriptor {
    case first
    case second
    case last
    case index(Int)
    case filename(PDFFilenameDescriptor)
    case introspecting(description: String,
                       _ closure: (_ pdf: PDFDocument) -> Bool)
}

extension PDFFileDescriptor {
    public var verboseDescription: String {
        switch self {
        case .first:
            return "first file"
        case .second:
            return "second file"
        case .last:
            return "last file"
        case .index(let idx):
            return "file with index \(idx)"
        case .filename(_):
            return "file with filename criteria"
        case .introspecting(let description, _):
            return "file matching \(description)"
        }
    }
}
