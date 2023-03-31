//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterFiles(_ files: PDFFilesDescriptor)
    
    case mergeFiles(_ files: PDFFilesDescriptor = .all, appendingTo: PDFFileDescriptor? = nil)
    
    // TODO: reorder or sort files
    
    case filterPages(file: PDFFileDescriptor, pages: PDFPageFilter)
    
    // TODO: copy pages
     case insertPages(
         fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
         toFile: PDFFileDescriptor, atPageIndex: Int,
         behavior: InterchangeBehavior
     )
    
    case reversePageOrder(file: PDFFileDescriptor)
    
    case replacePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPages: PDFPageFilter,
        behavior: InterchangeBehavior
    )
    
    case rotate(file: PDFFileDescriptor, pages: PDFPageFilter, rotation: PDFPageRotation)
    
    // TODO: case crop(pages: PDFPageFilter, area: Rect)
    
    // TODO: case flip(pages: PDFPageFilter, axis: Axis) // -> use Quartz filter?
    
    case filterAnnotations(file: PDFFileDescriptor, pages: PDFPageFilter, annotations: PDFAnnotationFilter)
    
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
            
        case .mergeFiles:
            return "Merge files"
            
        case let .filterPages(file, pages):
            return "Filter \(pages.verboseDescription) in \(file.verboseDescription)"
            
        case let .insertPages(fromFile, fromPages, toFile, atPageIndex, behavior):
            return "Insert \(fromPages.verboseDescription) from \(fromFile.verboseDescription) at page number \(atPageIndex + 1) in \(toFile.verboseDescription) by \(behavior.verboseDescription)"
            
        case let .reversePageOrder(file):
            return "Reverse page order in \(file.verboseDescription)"
            
        case let .replacePages(fromFile, fromPages, toFile, toPages, behavior):
            return "Replace \(toPages.verboseDescription) of \(toFile.verboseDescription) with \(fromPages.verboseDescription) from \(fromFile.verboseDescription) by \(behavior.verboseDescription)"
            
        case let .rotate(file, pages, rotation):
            return "Rotate \(pages.verboseDescription) in \(file.verboseDescription) \(rotation)"
            
        case let .filterAnnotations(file, pages, annotations):
            return "Filter \(annotations.verboseDescription) for \(pages.verboseDescription) in \(file.verboseDescription)"
        }
    }
}

extension PDFOperation {
    public enum InterchangeBehavior: Equatable, Hashable {
        case copy
        case move
    }
}

extension PDFOperation.InterchangeBehavior {
    public var verboseDescription: String {
        switch self {
        case .copy:
            return "copying"
        case .move:
            return "moving"
        }
    }
}
