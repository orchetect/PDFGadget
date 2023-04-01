//
//  PDFFileSplitDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFFileSplitDescriptor: Equatable, Hashable {
    case every(pageCount: Int)
    case at(pageIndexes: [Int])
    case splits(_ splits: [PDFOperation.PageAndFilename])
}

extension PDFFileSplitDescriptor {
    public var verboseDescription: String {
        switch self {
        case .every(let pageCount):
            return "every \(pageCount) page\(pageCount == 1 ? "" : "s")"
        case .at(let pageIndexes):
            return "at page indexes \(pageIndexes.map { String($0) }.joined(separator: ", "))"
        case .splits(let splits):
            return "at \(splits.count) splits"
        }
    }
}
