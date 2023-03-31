//
//  PDFFilesDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

/// Criteria to match an arbitrary number of PDF files.
public enum PDFFilesDescriptor: Equatable, Hashable {
    case all
    case first
    case second
    case last
    case index(_ idx: Int)
    case indexes(_ indexes: [Int])
    case indexRange(_ indexRange: ClosedRange<Int>)
    case filename(_ filenameDescriptor: PDFFilenameDescriptor)
    case introspecting(_ introspection: PDFFileIntrospection)
}

extension PDFFilesDescriptor {
    /// Returns `nil` in the event of an error.
    func filtering(_ inputs: [PDFDocument]) -> [PDFDocument]? {
        switch self {
        case .all:
            return inputs
            
        case .first:
            if let f = inputs.first { return [f] } else { return nil }
            
        case .second:
            guard inputs.count > 1 else { return nil}
            return [inputs[1]]
            
        case .last:
            if let l = inputs.last { return [l] } else { return nil }
            
        case .index(let idx):
            guard inputs.indices.contains(idx) else { return nil}
            return [inputs[idx]]
            
        case .indexes(let indexes):
            guard indexes.allSatisfy({ inputs.indices.contains($0) }) else { return nil }
            return indexes.reduce(into: []) { base, idx in
                base.append(inputs[idx])
            }
            
        case .indexRange(let indexRange):
            guard indexRange.allSatisfy({ inputs.indices.contains($0) }) else { return nil }
            return indexRange.reduce(into: []) { base, idx in
                base.append(inputs[idx])
            }
            
        case .filename(let filenameDescriptor):
            return inputs.filter { doc in
                guard let baseFilename = doc.filenameWithoutExtension else { return false }
                return filenameDescriptor.matches(baseFilename)
            }
            
        case .introspecting(let introspection):
            return inputs.filter { introspection.closure($0) }
            
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
        case .index(let idx):
            return "file with index \(idx)"
        case .indexes(let idxes):
            return "files with indexes \(idxes.map { String($0) }.joined(separator: ", "))"
        case .indexRange(let range):
            return "files with index range \(range.lowerBound)-\(range.upperBound))"
        case .filename(let filenameDescriptor):
            return "files with filename \(filenameDescriptor.verboseDescription)"
        case .introspecting(let introspection):
            return "files matching \(introspection.description)"
        }
    }
}
