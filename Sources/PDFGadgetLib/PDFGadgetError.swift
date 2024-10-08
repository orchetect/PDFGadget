//
//  PDFGadgetError.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

public enum PDFGadgetError: LocalizedError {
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
