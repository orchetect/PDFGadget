//
//  PDFPageFilter.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

public enum PDFPageFilter: Equatable, Hashable {
    case all
    case include(_ descriptors: [PDFPagesDescriptor])
    case exclude(_ descriptors: [PDFPagesDescriptor])
}

extension PDFPageFilter {
    func apply(
        to input: [Int],
        sort: Bool = true
    ) -> IndexesDiff {
        var included = input
        var isInclusive = true
        
        switch self {
        case .all:
            // no logic needed, just keep all input indexes
            isInclusive = true
            
        case let .include(descriptor):
            let diffed = Self.diff(indexes: included, descriptor, include: true)
            included = diffed.indexes
            isInclusive = diffed.allAreInclusive
            
        case let .exclude(descriptor):
            let diffed = Self.diff(indexes: included, descriptor, include: false)
            included = diffed.indexes
            isInclusive = diffed.allAreInclusive
        }
        
        if sort {
            included.sort()
        }
        
        let excluded = input.filter {
            !included.contains($0)
        }
        
        return IndexesDiff(
            original: input,
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
                let result = pagesDescriptor.apply(to: indexes)
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
            return "All"
            
        case let .include(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "Including \(pageSetsStr)"
            
        case let .exclude(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "Including \(pageSetsStr)"
        }
    }
}
