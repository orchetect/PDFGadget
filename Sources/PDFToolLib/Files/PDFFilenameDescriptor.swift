//
//  PDFFilenameDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFFilenameDescriptor {
    case matches(exactly: String)
    
    case starts(with: String)
    case ends(with: String)
    case contains(String)
    
    case doesNotStart(with: String)
    case doesNotEnd(with: String)
    case doesNotContain(String)
    
    // case matches(regex: Regex)
    // case doesNotMatch(regex: Regex)
}
