//
//  PDFOperationResult.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation

public enum PDFOperationResult: Equatable, Hashable {
    case noChange(reason: String? = nil)
    case changed
}
