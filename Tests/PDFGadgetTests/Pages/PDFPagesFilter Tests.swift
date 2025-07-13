//
//  PDFPagesFilter Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

@testable import PDFGadget
import Testing
import TestingExtensions

@Suite struct PDFPagesFilterTests {
    @Test func all() throws {
        let filter: PDFPagesFilter = .all
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [1, 3, 4, 5])
            #expect(filtered.excluded == [])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func include_OddNumbers() throws {
        let filter: PDFPagesFilter = .include([.oddNumbers])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [1, 4])
            #expect(filtered.excluded == [3, 5])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func include_EvenNumbers() throws {
        let filter: PDFPagesFilter = .include([.evenNumbers])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [3, 5])
            #expect(filtered.excluded == [1, 4])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func include_Multiple_isInclusive() throws {
        let filter: PDFPagesFilter = .include([
            .pages(indexes: [0]),
            .range(indexes: 2 ... 3)
        ])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5, 6])
            #expect(filtered.included == [1, 4, 5])
            #expect(filtered.excluded == [3, 6])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func include_Multiple_isNotInclusive_FirstNotInclusive() throws {
        let filter: PDFPagesFilter = .include([
            .pages(indexes: [4]),
            .range(indexes: 2 ... 3)
        ])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [4, 5])
            #expect(filtered.excluded == [1, 3])
            #expect(!filtered.isInclusive)
        }
    }
    
    @Test func include_Multiple_isNotInclusive_LastNotInclusive() throws {
        let filter: PDFPagesFilter = .include([
            .pages(indexes: [0]),
            .range(indexes: 2 ... 3)
        ])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4])
            #expect(filtered.included == [1, 4])
            #expect(filtered.excluded == [3])
            #expect(!filtered.isInclusive)
        }
    }
    
    @Test func exclude_OddNumbers() throws {
        let filter: PDFPagesFilter = .exclude([.oddNumbers])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [3, 5])
            #expect(filtered.excluded == [1, 4])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func exclude_EvenNumbers() throws {
        let filter: PDFPagesFilter = .exclude([.evenNumbers])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5])
            #expect(filtered.included == [1, 4])
            #expect(filtered.excluded == [3, 5])
            #expect(filtered.isInclusive)
        }
    }
    
    @Test func exclude_Multiple_isInclusive() throws {
        let filter: PDFPagesFilter = .exclude([
            .pages(indexes: [0]),
            .range(indexes: 2 ... 3)
        ])
        
        do {
            let filtered = filter.filtering([])
            #expect(filtered.included == [])
            #expect(filtered.excluded == [])
            #expect(!filtered.isInclusive)
        }
        
        do {
            let filtered = filter.filtering([1, 3, 4, 5, 6])
            #expect(filtered.included == [3, 6])
            #expect(filtered.excluded == [1, 4, 5])
            #expect(filtered.isInclusive)
        }
    }
}

#endif
