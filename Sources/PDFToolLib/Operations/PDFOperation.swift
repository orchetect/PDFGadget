//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    // TODO: create a new empty file
    // /// New empty PDF file.
    // case newFile
    
    /// Clone (duplicate) a loaded PDF file.
    case cloneFile(file: PDFFileDescriptor)
    
    /// Filter loaded PDF files.
    case filterFiles(_ files: PDFFilesDescriptor)
    
    /// Merge loaded PDF files.
    case mergeFiles(_ files: PDFFilesDescriptor = .all, appendingTo: PDFFileDescriptor? = nil)
    
    // TODO: reorder or sort files
    
    /// Filter page(s) of PDF file(s).
    case filterPages(file: PDFFileDescriptor, pages: PDFPageFilter)
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case copyPages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPageIndex: Int
    )
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case movePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPageIndex: Int
    )
    
    /// Reverse the page order of a PDF file.
    case reversePageOrder(file: PDFFileDescriptor)
    
    /// Replace existing page(s) with other page(s).
    case replacePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPageFilter,
        toFile: PDFFileDescriptor, toPages: PDFPageFilter,
        behavior: InterchangeBehavior
    )
    
    /// Rotate page(s) by a multiple of 90 degrees.
    /// Rotation can be absolute or relative to current page rotation (if any).
    case rotate(file: PDFFileDescriptor, pages: PDFPageFilter, rotation: PDFPageRotation)
    
    // TODO: case crop(pages: PDFPageFilter, area: Rect)
    
    // TODO: case flip(pages: PDFPageFilter, axis: Axis) // -> use Quartz filter?
    
    /// Filter annotation(s).
    case filterAnnotations(file: PDFFileDescriptor, pages: PDFPageFilter, annotations: PDFAnnotationFilter)
    
    // --> nil out all annotations' `userName: String?` property etc.
    // case removeAnnotationAuthors(fileIndex: Int, pages: PDFPageFilter, for: PDFAnnotationFilter)
    
    // TODO: text/freeText annotation: removal based on text content, allowing regex matching
    // TODO: text/freeText annotation: text search & replace, allowing regex matching
    
    // TODO: Title, Author, Subject, PDF Producer, Content creator, etc.
    // case fileMetadata(property: PDFFileProperty, value: String)
    
    // TODO: Draw text, shapes or images on page(s) - ie: a watermark or redaction
    // case overlay(text: String, in: Rect)
    
    // TODO: Modify style of existing text/freeText annotations
    
    // TODO: Logic operations or assertions
    // perhaps these could be nesting blocks using a result builder; might need to rethink the whole library API?
    // case expect(fileCount: Int)
    // case expect(file: PDFFileDescriptor, pageCount: Int) // could use enum: equals(), greaterThan(), lessThan()
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case let .cloneFile(file):
            return "Clone \(file.verboseDescription)"
            
        case let .filterFiles(files):
            return "Filter \(files.verboseDescription)"
            
        case .mergeFiles:
            return "Merge files"
            
        case let .filterPages(file, pages):
            return "Filter \(pages.verboseDescription) in \(file.verboseDescription)"
            
        case let .copyPages(fromFile, fromPages, toFile, toPageIndex):
            return "Copy \(fromPages.verboseDescription) from \(fromFile.verboseDescription), inserting at page number \(toPageIndex + 1) in \(toFile.verboseDescription)"
            
        case let .movePages(fromFile, fromPages, toFile, toPageIndex):
            return "Move \(fromPages.verboseDescription) from \(fromFile.verboseDescription), inserting at page number \(toPageIndex + 1) in \(toFile.verboseDescription)"
            
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
