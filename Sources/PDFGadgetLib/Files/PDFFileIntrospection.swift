//
//  PDFFileIntrospection.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if canImport(PDFKit)

import Foundation
import PDFKit

public struct PDFFileIntrospection {
    internal let id: UUID = .init()
    
    public var description: String
    public var closure: (_ pdf: PDFDocument) -> Bool
    
    public init(description: String, closure: @escaping (_ pdf: PDFDocument) -> Bool) {
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

#endif
