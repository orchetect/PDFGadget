//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterPages(PDFPageFilter)
    case reversePageOrder
    case replacePages(fromFile1: PDFPageFilter, toFile2: PDFPageFilter)
    
    // TODO: possible future features
    // case removeAnnotations(filter: PDFPageRange)
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .filterPages(filter):
            return "Filter pages: \(filter.verboseDescription)"
            
        case .reversePageOrder:
            return "Reverse Page Order"
            
        case let .replacePages(fromFilter, toFilter):
            return "Replace Pages \(toFilter.verboseDescription) in second file with pages \(fromFilter.verboseDescription) from first file"
        }
    }
}
