//
//  PDFToolError.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFToolError: LocalizedError {
    case validationError(String)
    case runtimeError(String)

    public var errorDescription: String? {
        switch self {
        case let .validationError(error):
            return "Validation error: \(error)"
        case let .runtimeError(error):
            return error
        }
    }
}
