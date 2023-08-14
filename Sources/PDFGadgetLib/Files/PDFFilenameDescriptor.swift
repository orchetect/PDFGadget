//
//  PDFFilenameDescriptor.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore

/// Criteria to match a PDF filename (excluding .pdf file extension).
public enum PDFFilenameDescriptor: Equatable, Hashable {
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

extension PDFFilenameDescriptor {
    public func matches(_ source: String) -> Bool {
        switch self {
        case .equals(let string):
            return source == string
        case .starts(let prefix):
            return source.starts(with: prefix)
        case .ends(let suffix):
            return source.hasSuffix(suffix)
        case .contains(let string):
            return source.contains(string)
        case .doesNotStart(let prefix):
            return !source.starts(with: prefix)
        case .doesNotEnd(let suffix):
            return !source.hasSuffix(suffix)
        case .doesNotContain(let string):
            return !source.contains(string)
        }
    }
}

extension PDFFilenameDescriptor {
    public var verboseDescription: String {
        switch self {
        case .equals(let string):
            return string.quoted
        case .starts(let prefix):
            return "starting with \(prefix.quoted)"
        case .ends(let suffix):
            return "ending with \(suffix.quoted)"
        case .contains(let string):
            return "containing \(string.quoted)"
        case .doesNotStart(let prefix):
            return "not starting with \(prefix.quoted)"
        case .doesNotEnd(let suffix):
            return "not ending with \(suffix.quoted)"
        case .doesNotContain(let string):
            return "not containing \(string.quoted)"
        }
    }
}
