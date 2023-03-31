//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterPages(file: PDFFileDescriptor, pages: PDFPageFilter)
    
    case reversePageOrder(file: PDFFileDescriptor)
    
    case replacePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPages: PDFPageFilter
    )
    
    // TODO: possible future features
    case rotate(file: PDFFileDescriptor, pages: PDFPageFilter, rotation: PDFPageRotation)
    // case crop(pages: PDFPageFilter, area: Rect)
    // case flip(pages: PDFPageFilter, axis: Axis) // -> use Quartz filter?
    
    case filterAnnotations(file: PDFFileDescriptor, pages: PDFPageFilter, annotations: PDFAnnotationFilter)
    
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
        case let .filterPages(file, pages):
            return "Filter \(pages.verboseDescription) in \(file)"
            
        case let .reversePageOrder(file):
            return "Reverse page order in \(file)"
            
        case let .replacePages(fromFile, fromPages, toFile, toPages):
            return "Replace \(toPages.verboseDescription) of \(toFile) with \(fromPages.verboseDescription) from \(fromFile)"
            
        case let .rotate(file, pages, rotation):
            return "Rotate \(pages.verboseDescription) in \(file) \(rotation)"
            
        case let .filterAnnotations(file, pages, annotations):
            return "Filter \(annotations.verboseDescription) for \(pages.verboseDescription) in \(file)"
        }
    }
}
