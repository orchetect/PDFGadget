//
//  PDFOperationResult.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFOperationResult: Equatable, Hashable {
    case noChange(reason: String? = nil)
    case changed
}
