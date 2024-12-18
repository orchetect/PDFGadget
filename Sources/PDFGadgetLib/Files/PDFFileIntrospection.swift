//
//  PDFFileIntrospection.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

/// Provides a closure for custom introspection logic on a `PDFDocument` instance.
public struct PDFFileIntrospection {
    let id: UUID = .init()
    
    public var description: String
    public var closure: @Sendable (_ pdf: PDFDocument) -> Bool
    
    public init(
        description: String,
        closure: @escaping @Sendable (_ pdf: PDFDocument) -> Bool
    ) {
        self.description = description
        self.closure = closure
    }
}

extension PDFFileIntrospection: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension PDFFileIntrospection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        // can't hash a closure
    }
}

extension PDFFileIntrospection: Sendable { }

#endif
