//
//  PDFOperation.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperation: Equatable, Hashable {
    case filterPages(PDFPageFilter)
    case reversePageOrder
    
    // TODO: possible future features
    // case removeAnnotations(filter: PDFPageRange)
}
