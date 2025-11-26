//
//  PDFOperation PDFTextDestination.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation

/// A destination to transfer or save plain text.
public enum PDFTextDestination {
    /// System pasteboard (clipboard).
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case pasteboard
    
    /// Save to a file on disk.
    case file(url: URL)
    
    /// Store in memory in the ``PDFProcessor`` instance's ``PDFProcessor/variables`` dictionary,
    /// keyed by the variable name.
    ///
    /// Appends or replaces variable.
    case variable(named: String)
}

extension PDFTextDestination: Equatable { }

extension PDFTextDestination: Hashable { }

extension PDFTextDestination: Sendable { }

extension PDFTextDestination {
    public var verboseDescription: String {
        switch self {
        case .pasteboard:
            return "pasteboard"
        case let .file(url):
            return url.absoluteString
        case let .variable(name):
            return "variable named \(name.quoted)"
        }
    }
}

#endif
