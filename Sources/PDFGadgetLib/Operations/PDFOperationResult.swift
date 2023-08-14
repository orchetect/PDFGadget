//
//  PDFOperationResult.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import Foundation

/// PDF editing operation result.
public enum PDFOperationResult: Equatable, Hashable {
    /// The operation did not result in any change to the PDF file.
    case noChange(reason: String? = nil)
    
    /// The operation resulted in one or more changes to the PDF file.
    case changed
}
