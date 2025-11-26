//
//  PDFProcessorError.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

public enum PDFProcessorError: LocalizedError {
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
