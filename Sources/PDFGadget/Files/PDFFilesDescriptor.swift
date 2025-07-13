//
//  PDFFilesDescriptor.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// Criteria to match an arbitrary number of PDF files.
public enum PDFFilesDescriptor {
    case all
    case first
    case second
    case last
    case index(_ idx: Int)
    case indexes(_ indexes: [Int])
    case indexRange(_ indexRange: ClosedRange<Int>)
    case filename(_ filenameDescriptor: PDFFilenameDescriptor)
    // case filenames(_ filenameDescriptors: [PDFFilenameDescriptor]) // TODO: add this
    case introspecting(_ introspection: PDFFileIntrospection)
}

extension PDFFilesDescriptor: Equatable { }

extension PDFFilesDescriptor: Hashable { }

extension PDFFilesDescriptor: Sendable { }

extension PDFFilesDescriptor {
    /// Returns `nil` in the event of an error.
    func filtering(_ inputs: [PDFFile]) -> [PDFFile]? {
        switch self {
        case .all:
            return inputs
            
        case .first:
            if let f = inputs.first { return [f] } else { return nil }
            
        case .second:
            guard inputs.count > 1 else { return nil }
            return [inputs[1]]
            
        case .last:
            if let l = inputs.last { return [l] } else { return nil }
            
        case let .index(idx):
            guard inputs.indices.contains(idx) else { return nil }
            return [inputs[idx]]
            
        case let .indexes(indexes):
            guard indexes.allSatisfy({ inputs.indices.contains($0) }) else { return nil }
            return indexes.reduce(into: []) { base, idx in
                base.append(inputs[idx])
            }
            
        case let .indexRange(indexRange):
            guard indexRange.allSatisfy({ inputs.indices.contains($0) }) else { return nil }
            return indexRange.reduce(into: []) { base, idx in
                base.append(inputs[idx])
            }
            
        case let .filename(filenameDescriptor):
            return inputs.filter { pdf in
                filenameDescriptor.matches(pdf.filenameForMatching)
            }
            
        case let .introspecting(introspection):
            return inputs.filter { introspection.closure($0.doc) }
        }
    }
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
        case let .index(idx):
            return "file with index \(idx)"
        case let .indexes(idxes):
            return "files with indexes \(idxes.map { String($0) }.joined(separator: ", "))"
        case let .indexRange(range):
            return "files with index range \(range.lowerBound)-\(range.upperBound))"
        case let .filename(filenameDescriptor):
            return "files with filename \(filenameDescriptor.verboseDescription)"
        case let .introspecting(introspection):
            return "files matching \(introspection.description)"
        }
    }
}

#endif
