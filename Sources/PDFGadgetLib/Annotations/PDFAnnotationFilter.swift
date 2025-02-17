//
//  PDFAnnotationFilter.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

public enum PDFAnnotationFilter {
    case all
    case none
    case include(_ types: [PDFAnnotationSubtype])
    case exclude(_ types: [PDFAnnotationSubtype])
}

extension PDFAnnotationFilter: Equatable { }

extension PDFAnnotationFilter: Hashable { }

extension PDFAnnotationFilter: Sendable { }

extension PDFAnnotationFilter {
    func filtering(
        _ inputs: [PDFAnnotation]
    ) -> [PDFAnnotation] {
        switch self {
        case .all:
            return inputs
            
        case .none:
            return []
            
        case let .include(types):
            return inputs.filter {
                $0.type(containedIn: types)
            }
            
        case let .exclude(types):
            return inputs.filter {
                !$0.type(containedIn: types)
            }
        }
    }
    
    func contains(
        _ input: PDFAnnotation
    ) -> Bool {
        switch self {
        case .all:
            return true
            
        case .none:
            return false
            
        case let .include(types):
            return input.type(containedIn: types)
            
        case let .exclude(types):
            return !input.type(containedIn: types)
        }
    }
}

extension PDFAnnotationFilter {
    public var verboseDescription: String {
        switch self {
        case .all:
            return "all annotations"
            
        case .none:
            return "no annotations"
            
        case let .include(types):
            let typesStr = types.map(\.rawValue.quoted).joined(separator: ", ")
            return "including \(typesStr) annotations"
            
        case let .exclude(types):
            let typesStr = types.map(\.rawValue.quoted).joined(separator: ", ")
            return "excluding \(typesStr) annotations"
        }
    }
}

#endif
