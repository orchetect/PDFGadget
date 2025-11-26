//
//  PDFFileSplitDescriptor.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
internal import SwiftExtensions
import PDFKit

/// Criteria for splitting a PDF file.
public enum PDFFileSplitDescriptor {
    case at(pageIndexes: [Int])
    case every(pageCount: Int)
    case pageIndexesAndFilenames([PDFOperation.PageRangeAndFilename])
    case pageNumbersAndFilenames([PDFOperation.PageRangeAndFilename])
    
    // TODO: add fileCount(Int) case to split a file into n number of files with equal number of pages each
}

extension PDFFileSplitDescriptor: Equatable { }

extension PDFFileSplitDescriptor: Hashable { }

extension PDFFileSplitDescriptor: Sendable { }

extension PDFFileSplitDescriptor {
    func splits(source: PDFFile) -> [PDFOperation.PageRangeAndFilename] {
        var splits: [PDFOperation.PageRangeAndFilename] = []
        
        switch self {
        case let .at(pageIndexes):
            // also removes dupes and sorts
            let ranges = convertPageIndexesToRanges(
                pageIndexes: pageIndexes,
                totalPageCount: source.doc.pageCount
            )
            for range in ranges {
                splits.append(.init(range, nil))
            }
            
        case var .every(nthPage):
            nthPage = nthPage.clamped(to: 1...)
            
            // Check to see that at least two resulting files will occur
            if nthPage >= source.doc.pageCount {
                return []
            }
            
            let ranges = (0 ..< source.doc.pageCount)
                .split(every: nthPage)
            splits = ranges.map { .init($0, String?.none) }
            
        case let .pageIndexesAndFilenames(pageIndexesAndFilenames):
            splits = pageIndexesAndFilenames
            
        case let .pageNumbersAndFilenames(pageNumbersAndFilenames):
            var mappedToIndexes = pageNumbersAndFilenames
            for index in mappedToIndexes.indices {
                mappedToIndexes[index].pageRange =
                    mappedToIndexes[index].pageRange.lowerBound - 1
                        ... mappedToIndexes[index].pageRange.upperBound - 1
            }
            splits = mappedToIndexes
        }
        
        return splits
    }
    
    func convertPageIndexesToRanges(pageIndexes: [Int], totalPageCount: Int) -> [ClosedRange<Int>] {
        var ranges: [ClosedRange<Int>] = []
        var lastIndex = 0
        for endIndex in pageIndexes.removingDuplicates(.afterFirstOccurrences).sorted() {
            ranges.append(lastIndex ... endIndex)
            lastIndex = endIndex + 1
        }
        // add final split
        if lastIndex <= totalPageCount {
            ranges.append(lastIndex ... totalPageCount - 1)
        }
        return ranges
    }
}

extension PDFFileSplitDescriptor {
    public var verboseDescription: String {
        switch self {
        case let .at(pageIndexes):
            return "at page indexes \(pageIndexes.map { String($0) }.joined(separator: ", "))"
        case let .every(pageCount):
            return "every \(pageCount) page\(pageCount == 1 ? "" : "s")"
        case let .pageIndexesAndFilenames(splits):
            return "at \(splits.count) named splits"
        case let .pageNumbersAndFilenames(splits):
            return "at \(splits.count) named splits"
        }
    }
}

#endif
