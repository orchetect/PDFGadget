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
    // case crop(pages: PDFPageFilter, area: Rect)
    // case flip(pages: PDFPageFilter, axis: Axis) // -> use Quartz filter?
    
    case filterAnnotations(fileIndex: Int, pages: PDFPageFilter, annotations: PDFAnnotationFilter)
    
    // --> nil out all annotations' `userName: String?` property etc.
//    case removeAnnotationAuthors(fileIndex: Int, pages: PDFPageFilter, for: PDFAnnotationFilter)
    
    // text/freeText annotation: removal based on text content, allowing regex matching
    // text/freeText annotation: text search & replace, allowing regex matching
    
    // Title, Author, Subject, PDF Producer, Content creator, etc.
    // case fileMetadata(property: PDFFileProperty, value: String)
    
    // Draw text, shapes or images on page(s) - ie: a watermark or redaction
    // case overlay(text: String, in: Rect)
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .filterPages(fileIndex, pages):
            return "Filter \(pages.verboseDescription) in file index \(fileIndex)"
            
        case let .reversePageOrder(fileIndex):
            return "Reverse page order in file index \(fileIndex)"
            
        case let .replacePages(fromFileIndex,
                               fromPages,
                               toFileIndex,
                               toPages):
            return "Replace \(toPages.verboseDescription) in file index \(toFileIndex) with \(fromPages.verboseDescription) from file index \(fromFileIndex)"
            
        case let .rotate(fileIndex, pages, rotation):
            return "Rotate \(pages.verboseDescription) in file index \(fileIndex) \(rotation)"
            
        case let .filterAnnotations(fileIndex, pages, annotations):
            return "Filter \(annotations.verboseDescription) for \(pages.verboseDescription) in file index \(fileIndex)"
        }
    }
}
