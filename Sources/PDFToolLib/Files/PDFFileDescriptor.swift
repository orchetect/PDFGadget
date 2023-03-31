//
//  PDFFileDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

/// Criteria to match a single PDF file.
public enum PDFFileDescriptor: Equatable, Hashable {
    case first
    case second
    case last
    case index(_ idx: Int)
    case filename(_ filenameDescriptor: PDFFilenameDescriptor)
    case introspecting(_ introspection: PDFFileIntrospection)
}

extension PDFFileDescriptor {
    func first(in inputs: [PDFDocument]) -> PDFDocument? {
        switch self {
        case .first:
            return inputs.first
            
        case .second:
            guard inputs.count > 1 else { return nil }
            return inputs[1]
            
        case .last:
            return inputs.last
            
        case .index(let idx):
            guard inputs.indices.contains(idx) else { return nil }
            return inputs[idx]
            
        case .filename(let filenameDescriptor):
            return inputs.first { doc in
                guard let baseFilename = doc.filenameWithoutExtension else { return false }
                return filenameDescriptor.matches(baseFilename)
            }
            
        case .introspecting(let introspection):
            return inputs.first(where: { introspection.closure($0) })
            
        }
    }
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
        case .filename(let filenameDescriptor):
            return "file with filename \(filenameDescriptor.verboseDescription)"
        case .introspecting(let introspection):
            return "file matching \(introspection.description)"
        }
    }
}
