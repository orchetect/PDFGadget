//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    /// New empty PDF file.
    case newFile
    
    /// Clone (duplicate) a loaded PDF file.
    case cloneFile(file: PDFFileDescriptor)
    
    /// Filter loaded PDF files.
    case filterFiles(_ files: PDFFilesDescriptor)
    
    /// Merge loaded PDF files.
    case mergeFiles(_ files: PDFFilesDescriptor = .all, appendingTo: PDFFileDescriptor? = nil)
    
    // TODO: reorder or sort files
    
    // TODO: collation stuff
    
    /// Filter page(s) of PDF file(s).
    case filterPages(file: PDFFileDescriptor, pages: PDFPagesFilter)
    
    /// Set new filename for a PDF file.
    case setFilename(file: PDFFileDescriptor, filename: String?)
    
    // TODO: additional setFilename cases, such as renaming all to sequential numbers etc.
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case copyPages(
        fromFile: PDFFileDescriptor, fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor, toPageIndex: Int? = nil
    )
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case movePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor, toPageIndex: Int? = nil
    )
    
    /// Reverse the page order of a PDF file.
    case reversePageOrder(file: PDFFileDescriptor, pages: PDFPagesFilter)
    
    /// Replace existing page(s) with other page(s).
    case replacePages(
        fromFile: PDFFileDescriptor, fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor, toPages: PDFPagesFilter,
        behavior: InterchangeBehavior
    )
    
    /// Rotate page(s) by a multiple of 90 degrees.
    /// Rotation can be absolute or relative to current page rotation (if any).
    case rotatePages(file: PDFFileDescriptor, pages: PDFPagesFilter, rotation: PDFPageRotation)
    
    /// Split file at certain page points into multiple files.
    /// The original file is discarded.
    case splitFile(file: PDFFileDescriptor, discardUnused: Bool = true, _ splits: PDFFileSplitDescriptor)
    
    // TODO: case crop(pages: PDFPagesFilter, area: Rect)
    
    // TODO: case flip(pages: PDFPagesFilter, axis: Axis) // -> use Quartz filter?
    
    /// Filter annotation(s).
    case filterAnnotations(file: PDFFileDescriptor, pages: PDFPagesFilter, annotations: PDFAnnotationFilter)
    
    // --> nil out all annotations' `userName: String?` property etc.
    // case removeAnnotationAuthors(fileIndex: Int, pages: PDFPagesFilter, for: PDFAnnotationFilter)
    
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

// MARK: - Static Constructors

extension PDFOperation {
    public static func copyPages(
        file: PDFFileDescriptor,
        from fromPages: PDFPagesFilter,
        toPageIndex: Int? = nil
    ) -> Self {
        .copyPages(fromFile: file, fromPages: fromPages, toFile: file, toPageIndex: toPageIndex)
    }
    
    public static func movePages(
        file: PDFFileDescriptor,
        from fromPages: PDFPagesFilter,
        toPageIndex: Int? = nil
    ) -> Self {
        .movePages(fromFile: file, fromPages: fromPages, toFile: file, toPageIndex: toPageIndex)
    }
    
    public static func replacePages(
        file: PDFFileDescriptor,
        from fromPages: PDFPagesFilter,
        to toPages: PDFPagesFilter,
        behavior: InterchangeBehavior
    ) -> Self {
        .replacePages(
            fromFile: file,
            fromPages: fromPages,
            toFile: file,
            toPages: toPages,
            behavior: behavior
        )
    }
}

extension PDFOperation {
    public var verboseDescription: String {
        switch self {
        case .newFile:
            return "New empty file"
            
        case let .cloneFile(file):
            return "Clone \(file.verboseDescription)"
            
        case let .filterFiles(files):
            return "Filter \(files.verboseDescription)"
            
        case .mergeFiles:
            return "Merge files"
            
        case let .setFilename(file, filename):
            if let filename {
                return "Set filename for \(file.verboseDescription) to \(filename.quoted)"
            } else {
                return "Reset filename for \(file.verboseDescription))"
            }
            
        case let .filterPages(file, pages):
            return "Filter \(pages.verboseDescription) in \(file.verboseDescription)"
            
        case let .copyPages(fromFile, fromPages, toFile, toPageIndex):
            let location = toPageIndex != nil
                ? "inserting at page number \(toPageIndex! + 1) in"
                : "appending to end of"
            return "Copy \(fromPages.verboseDescription) from \(fromFile.verboseDescription), \(location) \(toFile.verboseDescription)"
            
        case let .movePages(fromFile, fromPages, toFile, toPageIndex):
            let location = toPageIndex != nil
                ? "inserting at page number \(toPageIndex! + 1) in"
                : "appending to end of"
            return "Move \(fromPages.verboseDescription) from \(fromFile.verboseDescription), \(location) \(toFile.verboseDescription)"
            
        case let .reversePageOrder(file, pages):
            return "Reverse page order of \(pages.verboseDescription) in \(file.verboseDescription)"
            
        case let .replacePages(fromFile, fromPages, toFile, toPages, behavior):
            return "Replace \(toPages.verboseDescription) of \(toFile.verboseDescription) with \(fromPages.verboseDescription) from \(fromFile.verboseDescription) by \(behavior.verboseDescription)"
            
        case let .rotatePages(file, pages, rotation):
            return "Rotate \(pages.verboseDescription) in \(file.verboseDescription) \(rotation)"
            
        case let .splitFile(file, discardUnused, splits):
            return "Split \(file.verboseDescription) \(splits.verboseDescription)\(discardUnused ? ", discarding unused pages if any" : "")"
            
        case let .filterAnnotations(file, pages, annotations):
            return "Filter \(annotations.verboseDescription) for \(pages.verboseDescription) in \(file.verboseDescription)"
        }
    }
}
