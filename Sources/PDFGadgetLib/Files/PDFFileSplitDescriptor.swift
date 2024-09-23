//
//  PDFFileSplitDescriptor.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
internal import OTCore
import PDFKit

/// Criteria for splitting a PDF file.
public enum PDFFileSplitDescriptor: Equatable, Hashable {
    case at(pageIndexes: [Int])
    case every(pageCount: Int)
    case pageIndexesAndFilenames([PDFOperation.PageRangeAndFilename])
    case pageNumbersAndFilenames([PDFOperation.PageRangeAndFilename])
    
    // TODO: add fileCount(Int) case to split a file into n number of files with equal number of pages each
}

extension PDFFileSplitDescriptor {
    func splits(source: PDFFile) -> [PDFOperation.PageRangeAndFilename] {
        var splits: [PDFOperation.PageRangeAndFilename] = []
        
        switch self {
        case .at(let pageIndexes):
            // also removes dupes and sorts
            let ranges = convertPageIndexesToRanges(pageIndexes: pageIndexes, totalPageCount: source.doc.pageCount)
            for range in ranges {
                splits.append(.init(range, nil))
            }
            
        case .every(var nthPage):
            nthPage = nthPage.clamped(to: 1...)
            
            // Check to see that at least two resulting files will occur
            if nthPage >= source.doc.pageCount {
                return []
            }
            
            let ranges = (0 ..< source.doc.pageCount)
                .split(every: nthPage)
            splits = ranges.map { .init($0, String?.none) }
            
        case .pageIndexesAndFilenames(let pageIndexesAndFilenames):
            splits = pageIndexesAndFilenames
            
        case .pageNumbersAndFilenames(let pageNumbersAndFilenames):
            var mappedToIndexes = pageNumbersAndFilenames
            mappedToIndexes.indices.forEach {
                mappedToIndexes[$0].pageRange =
                    mappedToIndexes[$0].pageRange.lowerBound - 1
                        ... mappedToIndexes[$0].pageRange.upperBound - 1
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
        case .at(let pageIndexes):
            return "at page indexes \(pageIndexes.map { String($0) }.joined(separator: ", "))"
        case .every(let pageCount):
            return "every \(pageCount) page\(pageCount == 1 ? "" : "s")"
        case .pageIndexesAndFilenames(let splits):
            return "at \(splits.count) named splits"
        case .pageNumbersAndFilenames(let splits):
            return "at \(splits.count) named splits"
        }
    }
}

#endif
