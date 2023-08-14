//
//  PDFFileDescriptor.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// Criteria to match a single PDF file.
public enum PDFFileDescriptor: Equatable, Hashable {
    /// First file.
    case first
    
    /// Second file.
    case second
    
    /// Last file.
    case last
    
    /// File with given index (0-based).
    case index(_ idx: Int)
    
    /// File matching given filename descriptor.
    case filename(_ filenameDescriptor: PDFFilenameDescriptor)
    
    /// File matching against an introspection closure.
    case introspecting(_ introspection: PDFFileIntrospection)
}

extension PDFFileDescriptor {
    func first(in inputs: [PDFFile]) -> PDFFile? {
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
            return inputs.first { pdf in
                return filenameDescriptor.matches(pdf.filenameForMatching)
            }
            
        case .introspecting(let introspection):
            return inputs.first(where: { introspection.closure($0.doc) })
            
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

#endif
