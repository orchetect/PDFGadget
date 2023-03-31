//
//  PDFPageFilter.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

public enum PDFPageFilter: Equatable, Hashable {
    case all
    // case none
    case only(_ descriptors: [PDFPagesDescriptor])
    case drop(_ descriptors: [PDFPagesDescriptor])
}

extension PDFPageFilter {
    func filtering(_ inputs: [Int], sort: Bool = true) -> IndexesDiff {
        var included = inputs
        var isInclusive = true
        
        switch self {
        case .all:
            // no logic needed, just keep all input indexes
            isInclusive = true
            
        case let .only(descriptor):
            let diffed = Self.diff(indexes: included, descriptor, include: true)
            included = diffed.indexes
            isInclusive = diffed.allAreInclusive
            
        case let .drop(descriptor):
            let diffed = Self.diff(indexes: included, descriptor, include: false)
            included = diffed.indexes
            isInclusive = diffed.allAreInclusive
        }
        
        if sort {
            included.sort()
        }
        
        let excluded = inputs.filter {
            !included.contains($0)
        }
        
        return IndexesDiff(
            original: inputs,
            included: included,
            excluded: excluded,
            isInclusive: isInclusive
        )
    }
    
    private static func diff(
        indexes: [Int],
        _ pagesDescriptors: [PDFPagesDescriptor],
        include: Bool
    ) -> (indexes: [Int], allAreInclusive: Bool) {
        let filtered: (results: Set<Int>, isInclusive: Bool) = pagesDescriptors
            .reduce(into: (results: [], isInclusive: true)) { base, pagesDescriptor in
                let result = pagesDescriptor.filtering(indexes)
                if result.isInclusive == false { base.isInclusive = false }
                base.results.formUnion(result.indexes)
            }
        
        let indexes = include
            ? Array(filtered.results)
            : Array(indexes.filter { !filtered.results.contains($0) })
        
        let allAreInclusive = filtered.isInclusive
        
        return (indexes: indexes, allAreInclusive: allAreInclusive)
    }
}

extension PDFPageFilter {
    public var verboseDescription: String {
        switch self {
        case .all:
            return "all pages"
            
        case let .only(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "pages including \(pageSetsStr)"
            
        case let .drop(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "pages excluding \(pageSetsStr)"
        }
    }
}
