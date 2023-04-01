//
//  PDFFileSplitDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore
import PDFKit

public enum PDFFileSplitDescriptor: Equatable, Hashable {
    case at(pageIndexes: [Int])
    case every(pageCount: Int)
    case pageIndexesAndFilenames([ClosedRange<Int>: String?])
    case pageNumbersAndFilenames([ClosedRange<Int>: String?])
    
    // TODO: add fileCount(Int) case to split a file into n number of files with equal number of pages each
}

extension PDFFileSplitDescriptor {
    typealias PageRangeAndFilename = (pageRange: ClosedRange<Int>, filename: String?)
    
    func splits(source: PDFFile) -> [PageRangeAndFilename] {
        var splits: [PageRangeAndFilename] = []
        
        switch self {
        case .at(let pageIndexes):
            // also removes dupes and sorts
            let ranges = convertPageIndexesToRanges(pageIndexes: pageIndexes, totalPageCount: source.doc.pageCount)
            for range in ranges {
                splits.append((pageRange: range, filename: nil))
            }
            
        case .every(var nthPage):
            nthPage = nthPage.clamped(to: 1...)
            
            // Check to see that at least two resulting files will occur
            if nthPage >= source.doc.pageCount {
                return []
            }
            
            let ranges = (0 ..< source.doc.pageCount)
                .split(every: nthPage)
            splits = ranges.map { (pageRange: $0, filename: String?.none) }
            
        case .pageIndexesAndFilenames(let pageIndexesAndFilenames):
            // must sort since input is a dictionary
            for (indexRange, filename) in pageIndexesAndFilenames
                .sorted(by: { $0.key.lowerBound < $1.key.lowerBound })
            {
                splits.append((pageRange: indexRange, filename: filename))
            }
            
        case .pageNumbersAndFilenames(let pageNumbersAndFilenames):
            let mappedToIndexes = pageNumbersAndFilenames.mapDictionary { range, filename in
                (range.lowerBound - 1 ... range.upperBound - 1, filename)
            }
            return Self.pageIndexesAndFilenames(mappedToIndexes).splits(source: source)
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
