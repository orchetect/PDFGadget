//
//  PDFAnnotationFilter.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import PDFKit

public enum PDFAnnotationFilter: Equatable, Hashable {
    case all
    case none
    case only(_ types: [PDFAnnotationSubtype])
    case drop(_ types: [PDFAnnotationSubtype])
}

extension PDFAnnotationFilter {
    func apply(
        to inputs: [PDFAnnotation]
    ) -> [PDFAnnotation] {
        switch self {
        case .all:
            return inputs
            
        case .none:
            return []
            
        case let .only(types):
            return inputs.filter {
                $0.type(containedIn: types)
            }
            
        case let .drop(types):
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
            
        case let .only(types):
            return input.type(containedIn: types)
            
        case let .drop(types):
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
            
        case let .only(types):
            let typesStr = types.map(\.rawValue).joined(separator: ", ")
            return "including \(typesStr) annotations"
            
        case let .drop(types):
            let typesStr = types.map(\.rawValue).joined(separator: ", ")
            return "excluding \(typesStr) annotations"
        }
    }
}
