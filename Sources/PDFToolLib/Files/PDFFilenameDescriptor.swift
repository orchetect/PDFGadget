//
//  PDFFilenameDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

public enum PDFFilenameDescriptor: Equatable, Hashable {
    case equals(String)
    
    case starts(with: String)
    case ends(with: String)
    case contains(String)
    
    case doesNotStart(with: String)
    case doesNotEnd(with: String)
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
