//
//  PDFPageFilter.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

public enum PDFPageFilter: Equatable, Hashable {
    case all
    case include(_ pageSets: [PDFPageSet], IndexStyle)
    case exclude(_ pageSets: [PDFPageSet], IndexStyle)
}

extension PDFPageFilter {
    func apply(to pageNumbers: [Int]) -> [Int] {
        var pageNumbers = pageNumbers
        
        func diff(_ pageSets: [PDFPageSet], _ indexStyle: IndexStyle, include: Bool) -> [Int] {
            var results: Set<Int> = []
            pageSets.forEach {
                let result = $0.apply(to: pageNumbers, explicit: indexStyle == .explicit)
                results.formUnion(result)
            }
            if include {
                return Array(results)
            } else {
                return Array(pageNumbers.filter { !results.contains($0) })
            }
        }
        
        switch self {
        case .all:
            break
            
        case let .include(pageSets, indexStyle):
            pageNumbers = diff(pageSets, indexStyle, include: true)
            
        case let .exclude(pageSets, indexStyle):
            pageNumbers = diff(pageSets, indexStyle, include: false)
        }
        
        pageNumbers.sort()
        return pageNumbers
    }
}

extension PDFPageFilter {
    public var verboseDescription: String {
        switch self {
        case .all:
            return "All"
            
        case let .include(pageSets, indexStyle):
            let pageSetsStr = pageSets.map(\.verboseDescription).joined(separator: ", ")
            return "Including \(pageSetsStr) using \(indexStyle.verboseDescription)"
            
        case let .exclude(pageSets, indexStyle):
            let pageSetsStr = pageSets.map(\.verboseDescription).joined(separator: ", ")
            return "Including \(pageSetsStr) using \(indexStyle.verboseDescription)"
        }
    }
}

extension PDFPageFilter {
    public enum IndexStyle: Equatable, Hashable {
        /// Explicit page numbers.
        case explicit
        
        /// Index offsets based on the array of input page numbers.
        case offset
        
        public var verboseDescription: String {
            switch self {
            case .explicit:
                return "explicit page numbering"
                
            case .offset:
                return "offset page numbering"
            }
        }
    }
}
