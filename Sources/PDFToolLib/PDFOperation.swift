//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterPages(fileIndex: Int, pages: PDFPageFilter)
    
    case reversePageOrder(fileIndex: Int)
    
    case replacePages(
        fromFileIndex: Int,
        fromPages: PDFPageFilter,
        toFileIndex: Int,
        toPages: PDFPageFilter
    )
    
    // TODO: possible future features
    case rotate(fileIndex: Int, pages: PDFPageFilter, rotation: PDFPageRotation)
    // case flip(pages: PDFPageFilter, axis: Axis)
    // case crop(pages: PDFPageFilter, area: Rect)
    // case removeAnnotations(onPages: PDFPageFilter)
    
    // Title, Author, Subject, PDF Producer, Content creator, etc.
    // case fileMetadata(property: PDFFileProperty, value: String)
    
    // Draw text, shapes or images on page(s) - ie: a watermark or redaction
    // case overlay(text: String, in: Rect)
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .filterPages(fileIndex, pages):
            return "Filter Pages: \(pages.verboseDescription) in file index \(fileIndex)"
            
        case let .reversePageOrder(fileIndex):
            return "Reverse Page Order in file index \(fileIndex)"
            
        case let .replacePages(fromFileIndex,
                               fromPages,
                               toFileIndex,
                               toFilter):
            return "Replace Pages \(toFilter.verboseDescription) in file index \(toFileIndex) with pages \(fromFilter.verboseDescription) from file index \(fromFileIndex)"
            
        case let .rotate(fileIndex: fileIndex, pages: pagesFilter, rotation: rotation):
            return "Rotate Pages \(pagesFilter.verboseDescription) in file index \(fileIndex) \(rotation)"
        }
    }
}
