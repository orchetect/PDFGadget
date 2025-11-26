//
//  PDFPagesFilter.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
internal import SwiftExtensions

/// Criteria to filter PDF pages.
public enum PDFPagesFilter {
    case all
    // case none
    case include(_ descriptors: [PDFPagesDescriptor])
    case exclude(_ descriptors: [PDFPagesDescriptor])
}

extension PDFPagesFilter: Equatable { }

extension PDFPagesFilter: Hashable { }

extension PDFPagesFilter: Sendable { }

extension PDFPagesFilter {
    func filtering(_ inputs: [Int], sort: Bool = true) -> IndexesDiff {
        var included = inputs
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

extension PDFPagesFilter {
    public var verboseDescription: String {
        switch self {
        case .all:
            return "all pages"
            
        case let .include(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "pages including \(pageSetsStr)"
            
        case let .exclude(descriptors):
            let pageSetsStr = descriptors.map(\.verboseDescription).joined(separator: ", ")
            return "pages excluding \(pageSetsStr)"
        }
    }
}

#endif
