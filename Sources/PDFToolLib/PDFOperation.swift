//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterPages(fileIndex: Int, PDFPageFilter)
    
    case reversePageOrder(fileIndex: Int)
    
    case replacePages(
        fromFileIndex: Int,
        fromFilter: PDFPageFilter,
        toFileIndex: Int,
        toFilter: PDFPageFilter
    )
    
    // TODO: possible future features
    case rotate(fileIndex: Int, pages: PDFPageFilter, rotation: PDFPageRotation)
    // case flip(pages: PDFPageFilter, axis: Axis)
    // case crop(pages: PDFPageFilter, area: Rect)
    // case removeAnnotations(onPages: PDFPageFilter)
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .filterPages(fileIndex, filter):
            return "Filter pages: \(filter.verboseDescription) in file index \(fileIndex)"
            
        case let .reversePageOrder(fileIndex):
            return "Reverse Page Order in file index \(fileIndex)"
            
        case let .replacePages(fromFileIndex,
                               fromFilter,
                               toFileIndex,
                               toFilter):
            return "Replace Pages \(toFilter.verboseDescription) in file index \(toFileIndex) with pages \(fromFilter.verboseDescription) from file index \(fromFileIndex)"
            
        case let .rotate(fileIndex: fileIndex, pages: pagesFilter, rotation: rotation):
            return "Rotate Pages \(pagesFilter.verboseDescription) in file index \(fileIndex) \(rotation)"
        }
    }
}
