//
//  PDFPagesDescriptor Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

@testable import PDFGadgetLib
import Testing
import TestingExtensions

@Suite struct PDFPagesDescriptorTests {
    @Test func hashable() throws {
        let descriptors: Set<PDFPagesDescriptor> = [
            .oddNumbers,
            .oddNumbers,
            
            .evenNumbers,
            .evenNumbers,
            
            .every(nthPage: 1, includeFirst: true),
            .every(nthPage: 1, includeFirst: true),
            
            .every(nthPage: 2, includeFirst: true),
            .every(nthPage: 2, includeFirst: true),
            
            .range(indexes: 1 ... 5),
            .range(indexes: 1 ... 5),
            
            .range(indexes: 1 ... 6),
            .range(indexes: 1 ... 6),
            
            .openRange(startIndex: 1),
            .openRange(startIndex: 1),
            
            .openRange(startIndex: 2),
            .openRange(startIndex: 2),
            
            .pages(indexes: [1, 2]),
            .pages(indexes: [1, 2]),
            
            .pages(indexes: [3, 4]),
            .pages(indexes: [3, 4])
        ]
        
        #expect(descriptors.count == 10)
    }
    
    @Test func hashable_EdgeCases() throws {
        // .page() page order is an array, not a set.
        #expect(
            Set<PDFPagesDescriptor>([.pages(indexes: [1, 2]), .pages(indexes: [2, 1])]) ==
            [.pages(indexes: [1, 2]), .pages(indexes: [2, 1])]
        )
    }
    
    @Test func containsSamePages() throws {
        func isSame(_ lhs: PDFPagesDescriptor, _ rhs: PDFPagesDescriptor? = nil) {
            let rhs = rhs ?? lhs
            #expect(
                lhs.containsSamePages(as: rhs),
                "\(lhs) is not the same as \(rhs)"
            )
        }
        
        // baseline cases
        
        let sets = [PDFPagesDescriptor]([
            .oddNumbers,
            .evenNumbers,
            .every(nthPage: 1, includeFirst: true),
            .range(indexes: 1 ... 5),
            .openRange(startIndex: 1),
            .pages(indexes: [1, 2])
        ])
        
        sets.forEach { isSame($0) }
        
        // specific conditions
        
        isSame(.pages(indexes: [1, 2]), .pages(indexes: [2, 1]))
        
        // false conditions
        
        #expect(!PDFPagesDescriptor.oddNumbers.containsSamePages(as: .evenNumbers))
    }
    
    @Test func oddNumbers() throws {
        let descriptor: PDFPagesDescriptor = .oddNumbers
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0]) ==
            .init(indexes: [0], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1]) ==
            .init(indexes: [0], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1, 2, 3, 4]) ==
            .init(indexes: [0, 2, 4], isInclusive: true)
        )
    }
    
    @Test func evenNumbers() throws {
        let descriptor: PDFPagesDescriptor = .evenNumbers
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0, 1]) ==
            .init(indexes: [1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0, 1, 2, 3, 4]) ==
            .init(indexes: [1, 3], isInclusive: true)
        )
    }
    
    @Test func everyNthPage_1() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 1, includeFirst: true)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0]) ==
            .init(indexes: [0], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1]) ==
            .init(indexes: [0, 1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1, 2, 3, 4]) ==
            .init(indexes: [0, 1, 2, 3, 4], isInclusive: true)
        )
    }
    
    @Test func everyNthPage_2_IncludeFirst() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 2, includeFirst: true)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0]) ==
            .init(indexes: [0], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1]) ==
            .init(indexes: [0], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([0, 1, 2, 3, 4]) ==
            .init(indexes: [0, 2, 4], isInclusive: true)
        )
    }
    
    @Test func everyNthPage_2_DoNotIncludeFirst() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 2, includeFirst: false)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0, 1]) ==
            .init(indexes: [1], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([0, 1, 2, 3, 4]) ==
            .init(indexes: [1, 3], isInclusive: true)
        )
    }
    
    @Test func range() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1 ..< 3)
        print(descriptor.verboseDescription)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [6], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8]) ==
            .init(indexes: [6, 7], isInclusive: true)
        )
    }
    
    @Test func closedRange() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1 ... 3)
        print(descriptor.verboseDescription)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [6], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [6, 7], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8]) ==
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8, 9]) ==
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
    }
    
    @Test func partialRangeFrom() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1...)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [6], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8]) ==
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8, 9]) ==
            .init(indexes: [6, 7, 8, 9], isInclusive: true)
        )
    }
    
    @Test func partialRangeUpTo() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: ..<2)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [1], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [5, 6], isInclusive: true)
        )
    }
    
    @Test func partialRangeThrough() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: ...2)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [1], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [5, 6], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [5, 6, 7], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8]) ==
            .init(indexes: [5, 6, 7], isInclusive: true)
        )
    }
    
    @Test func openRange() throws {
        let descriptor: PDFPagesDescriptor = .openRange(startIndex: 1)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([1]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [6], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8]) ==
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8, 9]) ==
            .init(indexes: [6, 7, 8, 9], isInclusive: true)
        )
    }
    
    @Test func first() throws {
        let descriptor: PDFPagesDescriptor = .first(count: 2)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5]) ==
            .init(indexes: [5], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [5, 6], isInclusive: true)
        )
    }
    
    @Test func last() throws {
        let descriptor: PDFPagesDescriptor = .last(count: 2)
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5]) ==
            .init(indexes: [5], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7]) ==
            .init(indexes: [6, 7], isInclusive: true)
        )
    }
    
    @Test func pages() throws {
        let descriptor: PDFPagesDescriptor = .pages(indexes: [1, 3, 4])
        
        #expect(
            descriptor.filtering([]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5]) ==
            .init(indexes: [], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6]) ==
            .init(indexes: [6], isInclusive: false)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8, 9]) ==
            .init(indexes: [6, 8, 9], isInclusive: true)
        )
        
        #expect(
            descriptor.filtering([5, 6, 7, 8, 9, 10]) ==
            .init(indexes: [6, 8, 9], isInclusive: true)
        )
    }
}
