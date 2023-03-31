//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterFiles(_ files: PDFFilesDescriptor)
    
    // TODO: reorder or sort files
    
    case filterPages(file: PDFFileDescriptor, pages: PDFPageFilter)
    
    case reversePageOrder(file: PDFFileDescriptor)
    
    case replacePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPages: PDFPageFilter
    )
    
    case rotate(file: PDFFileDescriptor, pages: PDFPageFilter, rotation: PDFPageRotation)
    
    // TODO: case crop(pages: PDFPageFilter, area: Rect)
    
    // TODO: case flip(pages: PDFPageFilter, axis: Axis) // -> use Quartz filter?
    
    case filterAnnotations(file: PDFFileDescriptor, pages: PDFPageFilter, annotations: PDFAnnotationFilter)
    
    // TODO: merge file(s) by sequentially appending each file to the end and result in one file
    // case mergeFiles
    
    // --> nil out all annotations' `userName: String?` property etc.
    // case removeAnnotationAuthors(fileIndex: Int, pages: PDFPageFilter, for: PDFAnnotationFilter)
    
    // TODO: text/freeText annotation: removal based on text content, allowing regex matching
    // TODO: text/freeText annotation: text search & replace, allowing regex matching
    
    // TODO: Title, Author, Subject, PDF Producer, Content creator, etc.
    // case fileMetadata(property: PDFFileProperty, value: String)
    
    // TODO: Draw text, shapes or images on page(s) - ie: a watermark or redaction
    // case overlay(text: String, in: Rect)
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .filterFiles(files):
            return "Filter \(files.verboseDescription)"
            
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
