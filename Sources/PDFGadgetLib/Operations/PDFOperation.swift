//
//  PDFOperation.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// PDF editing operations.
public enum PDFOperation {
    // MARK: - File Operations
    
    /// New empty PDF file.
    case newFile
    
    /// Clone (duplicate) a loaded PDF file.
    case cloneFile(file: PDFFileDescriptor)
    
    /// Filter loaded PDF files.
    case filterFiles(_ files: PDFFilesDescriptor)
    
    /// Merge loaded PDF files.
    case mergeFiles(
        _ files: PDFFilesDescriptor = .all,
        appendingTo: PDFFileDescriptor? = nil
    )
    
    // TODO: reorder or sort files
    
    /// Split file at certain page points into multiple files.
    /// The original file is discarded.
    case splitFile(
        file: PDFFileDescriptor,
        discardUnused: Bool = true,
        _ splits: PDFFileSplitDescriptor
    )
    
    /// Set new filename for a PDF file (excluding .pdf file extension).
    /// Passing `nil` resets the filename.
    case setFilename(file: PDFFileDescriptor, filename: String?)
    
    /// Set new filenames for one or more PDF files (excluding .pdf file extension).
    /// Passing `nil` for a filename resets that filename.
    case setFilenames(files: PDFFilesDescriptor = .all, filenames: [String?])
    
    /// Removes file attributes (metadata).
    case removeFileAttributes(files: PDFFilesDescriptor)
    
    /// Set or clear an attribute for one or more files.
    case setFileAttribute(
        files: PDFFilesDescriptor,
        _ attribute: PDFDocumentAttribute,
        value: String?
    )
    
    // MARK: - Page Operations
    
    // TODO: collation stuff
    
    /// Filter page(s) of PDF file(s).
    case filterPages(file: PDFFileDescriptor, pages: PDFPagesFilter)
    
    // TODO: additional setFilename cases, such as renaming all to sequential numbers etc.
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case copyPages(
        fromFile: PDFFileDescriptor,
        fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor,
        toPageIndex: Int? = nil
    )
    
    /// Copy page(s) within the same PDF file or from one file to another.
    case movePages(
        fromFile: PDFFileDescriptor,
        fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor,
        toPageIndex: Int? = nil
    )
    
    /// Replace existing page(s) with other page(s).
    case replacePages(
        fromFile: PDFFileDescriptor,
        fromPages: PDFPagesFilter,
        toFile: PDFFileDescriptor,
        toPages: PDFPagesFilter,
        behavior: InterchangeBehavior
    )
    
    /// Reverse the page order of a PDF file.
    case reversePageOrder(file: PDFFileDescriptor, pages: PDFPagesFilter)
    
    /// Rotate page(s) by a multiple of 90 degrees.
    /// Rotation can be absolute or relative to current page rotation (if any).
    case rotatePages(files: PDFFilesDescriptor, pages: PDFPagesFilter, rotation: PDFPageRotation)
    
    /// Crop page(s) by the given area descriptor.
    ///
    /// For scaling descriptors, a value of `1.0` represents 1:1 scale (no change).
    /// A crop cannot be larger than the source page's dimensions -- if a crop operation results in
    /// bounds that extend past the original media box, the crop will be reduced to the extents of
    /// the existing page.
    ///
    /// - Parameters:
    ///   - files: File(s).
    ///   - pages: Page(s).
    ///   - area: Area descriptor.
    ///   - apply: If `absolute`, the crop applied to the original media box dimensions,
    ///     even if a crop already exists (effectively, the crop is replaced and not augmented).
    ///     If `relative`, the the crop operation is applied relatively - if no crop exists, it is applied
    ///     to the media box, but if a crop exists, the existing crop is augmented.
    case cropPages(
        files: PDFFilesDescriptor,
        pages: PDFPagesFilter,
        area: PDFPageArea,
        apply: PDFOperation.ChangeBehavior = .relative
    )
    
    // TODO: case flip(file: PDFFileDescriptor, pages: PDFPagesFilter, axis: Axis) // -> use Quartz filter?
    
    // MARK: - Page Content Operations
    
    /// Filter annotation(s).
    case filterAnnotations(
        files: PDFFilesDescriptor,
        pages: PDFPagesFilter,
        annotations: PDFAnnotationFilter
    )
    
    /// Burn in annotations when exporting file to disk.
    /// This applies to an entire file and cannot be applied to individual pages.
    /// (macOS 13+)
    case burnInAnnotations(files: PDFFilesDescriptor)
    
    // --> nil out all annotations' `userName: String?` property etc.
    // case removeAnnotationAuthors(files: PDFFilesDescriptor, pages: PDFPagesFilter, for: PDFAnnotationFilter)
    
    // TODO: text/freeText annotation: removal based on text content, allowing regex matching
    // TODO: text/freeText annotation: text search & replace, allowing regex matching
    
    // TODO: Title, Author, Subject, PDF Producer, Content creator, etc.
    // case setFileMetadata(files: PDFFilesDescriptor, property: PDFFileProperty, value: String)
    
    // TODO: Draw text, shapes or images on page(s) - ie: a watermark or redaction
    // case addPageElement(files: PDFFilesDescriptor, pages: PDFPagesFilter, text: String, in: Rect)
    
    // TODO: Modify style of existing text/freeText annotations
    
    // TODO: Logic operations or assertions
    // perhaps these could be nesting blocks using a result builder; might need to rethink the whole library API?
    // case expect(fileCount: Int)
    // case expect(file: PDFFileDescriptor, pageCount: Int) // could use enum: equals(), greaterThan(), lessThan()
    
    /// Extract plain text content and send it to the specified destination.
    case extractPlainText(
        file: PDFFileDescriptor,
        pages: PDFPagesFilter,
        to: PDFTextDestination,
        pageBreak: PDFTextPageBreak
    )
    
    /// Attempts to remove document protections.
    case removeProtections(files: PDFFilesDescriptor)
}

extension PDFOperation: Equatable { }

extension PDFOperation: Hashable { }

extension PDFOperation: Sendable { }

// MARK: - Static Constructors

extension PDFOperation {
    /// Copy page(s) within the same PDF file or from one file to another.
    public static func copyPages(
        file: PDFFileDescriptor,
        from fromPages: PDFPagesFilter,
        toPageIndex: Int? = nil
    ) -> Self {
        .copyPages(fromFile: file, fromPages: fromPages, toFile: file, toPageIndex: toPageIndex)
    }
    
    /// Copy page(s) within the same PDF file or from one file to another.
    public static func movePages(
        file: PDFFileDescriptor,
        from fromPages: PDFPagesFilter,
        toPageIndex: Int? = nil
    ) -> Self {
        .movePages(fromFile: file, fromPages: fromPages, toFile: file, toPageIndex: toPageIndex)
    }
    
    /// Replace existing page(s) with other page(s).
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
            
        case let .splitFile(file, discardUnused, splits):
            return "Split \(file.verboseDescription) \(splits.verboseDescription)\(discardUnused ? ", discarding unused pages if any" : "")"
            
        case let .setFilename(file, filename):
            if let filename {
                return "Set filename for \(file.verboseDescription) to \(filename.quoted) (without extension)"
            } else {
                return "Reset filename for \(file.verboseDescription))"
            }
            
        case let .setFilenames(files, filenames):
            let formattedFilenames = filenames
                .map { $0 ?? "<reset>" }
                .map { $0.quoted }
                .joined(separator: ", ")
            return "Set filename(s) for \(files.verboseDescription) to \(formattedFilenames)"
            
        case let .removeFileAttributes(files):
            return "Remove attributes (metadata) for \(files.verboseDescription)"
            
        case let .setFileAttribute(files, attr, value):
            if let value {
                return "Set \(attr.rawValue) attribute value \(value.quoted) for \(files.verboseDescription)"
            } else {
                return "Remove \(attr.rawValue) attribute from \(files.verboseDescription)"
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
            
        case let .replacePages(fromFile, fromPages, toFile, toPages, behavior):
            return "Replace \(toPages.verboseDescription) of \(toFile.verboseDescription) with \(fromPages.verboseDescription) from \(fromFile.verboseDescription) by \(behavior.verboseDescription)"
            
        case let .reversePageOrder(file, pages):
            return "Reverse page order of \(pages.verboseDescription) in \(file.verboseDescription)"
            
        case let .rotatePages(files, pages, rotation):
            return "Rotate \(pages.verboseDescription) in \(files.verboseDescription) \(rotation.verboseDescription)"
            
        case let .cropPages(files, pages, area, process):
            return "Crop \(pages.verboseDescription) in \(files.verboseDescription) to \(area.verboseDescription) (\(process.verboseDescription))"
            
        case let .filterAnnotations(files, pages, annotations):
            return "Filter annotations \(annotations.verboseDescription) for \(pages.verboseDescription) in \(files.verboseDescription)"
            
        case let .burnInAnnotations(files):
            return "Burn in annotations for \(files.verboseDescription)"
            
        case let .extractPlainText(file, pages, destination, _ /* pageBreak */ ):
            return "Extract plain text from \(pages.verboseDescription) in \(file.verboseDescription) to \(destination.verboseDescription)"
            
        case .removeProtections:
            return "Remove protections"
        }
    }
}

#endif
