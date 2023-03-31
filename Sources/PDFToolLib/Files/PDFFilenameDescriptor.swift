//
//  PDFFilenameDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFFilenameDescriptor {
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
