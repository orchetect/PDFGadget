//
//  PDFPagesDescriptor FilterResult.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

extension PDFPagesDescriptor {
    public struct FilterResult {
        let indexes: [Int]
        let isInclusive: Bool
    }
}

extension PDFPagesDescriptor.FilterResult: Equatable { }

extension PDFPagesDescriptor.FilterResult: Hashable { }

extension PDFPagesDescriptor.FilterResult: Sendable { }
