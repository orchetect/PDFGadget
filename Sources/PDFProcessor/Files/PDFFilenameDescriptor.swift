//
//  PDFFilenameDescriptor.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
internal import SwiftExtensions

/// Criteria to match a PDF filename (excluding .pdf file extension).
public enum PDFFilenameDescriptor {
    /// Exact full string match.
    case equals(String)
    
    /// Filename that starts with the given string.
    case starts(with: String)
    
    /// Filename that ends with the given string.
    case ends(with: String)
    
    /// Filename that contains the given string.
    case contains(String)
    
    /// Filename that does not start with the given string.
    case doesNotStart(with: String)
    
    /// Filename that does not end with the given string.
    case doesNotEnd(with: String)
    
    /// Filename that does not contain the given string.
    case doesNotContain(String)
    
    // case matches(regex: Regex)
    
    // case doesNotMatch(regex: Regex)
}

extension PDFFilenameDescriptor: Equatable { }

extension PDFFilenameDescriptor: Hashable { }

extension PDFFilenameDescriptor: Sendable { }

extension PDFFilenameDescriptor {
    public func matches(_ source: String) -> Bool {
        switch self {
        case let .equals(string):
            return source == string
        case let .starts(prefix):
            return source.starts(with: prefix)
        case let .ends(suffix):
            return source.hasSuffix(suffix)
        case let .contains(string):
            return source.contains(string)
        case let .doesNotStart(prefix):
            return !source.starts(with: prefix)
        case let .doesNotEnd(suffix):
            return !source.hasSuffix(suffix)
        case let .doesNotContain(string):
            return !source.contains(string)
        }
    }
}

extension PDFFilenameDescriptor {
    public var verboseDescription: String {
        switch self {
        case let .equals(string):
            return string.quoted
        case let .starts(prefix):
            return "starting with \(prefix.quoted)"
        case let .ends(suffix):
            return "ending with \(suffix.quoted)"
        case let .contains(string):
            return "containing \(string.quoted)"
        case let .doesNotStart(prefix):
            return "not starting with \(prefix.quoted)"
        case let .doesNotEnd(suffix):
            return "not ending with \(suffix.quoted)"
        case let .doesNotContain(string):
            return "not containing \(string.quoted)"
        }
    }
}
