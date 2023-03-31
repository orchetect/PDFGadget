//
//  PDFPagesDescriptor Tests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib

final class PDFPagesDescriptorTests: XCTestCase {
    func testHashable() throws {
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
        
        XCTAssertEqual(descriptors.count, 10)
    }
    
    func testHashable_EdgeCases() throws {
        // .page() page order is an array, not a set.
        XCTAssertEqual(
            Set<PDFPagesDescriptor>([.pages(indexes: [1, 2]), .pages(indexes: [2, 1])]),
            [.pages(indexes: [1, 2]), .pages(indexes: [2, 1])]
        )
    }
    
    func testContainsSamePages() throws {
        func isSame(_ lhs: PDFPagesDescriptor, _ rhs: PDFPagesDescriptor? = nil) {
            let rhs = rhs ?? lhs
            XCTAssertTrue(lhs.containsSamePages(as: rhs),
            "\(lhs) is not the same as \(rhs)")
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
        
        XCTAssertFalse(PDFPagesDescriptor.oddNumbers.containsSamePages(as: .evenNumbers))
    }
    
    func testOddNumbers() throws {
        let descriptor: PDFPagesDescriptor = .oddNumbers
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0]),
            .init(indexes: [0], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1]),
            .init(indexes: [0], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1, 2, 3, 4]),
            .init(indexes: [0, 2, 4], isInclusive: true)
        )
    }
    
    func testEvenNumbers() throws {
        let descriptor: PDFPagesDescriptor = .evenNumbers
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1]),
            .init(indexes: [1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1, 2, 3, 4]),
            .init(indexes: [1, 3], isInclusive: true)
        )
    }
    
    func testEveryNthPage_1() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 1, includeFirst: true)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0]),
            .init(indexes: [0], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1]),
            .init(indexes: [0, 1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1, 2, 3, 4]),
            .init(indexes: [0, 1, 2, 3, 4], isInclusive: true)
        )
    }
    
    func testEveryNthPage_2_IncludeFirst() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 2, includeFirst: true)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0]),
            .init(indexes: [0], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1]),
            .init(indexes: [0], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1, 2, 3, 4]),
            .init(indexes: [0, 2, 4], isInclusive: true)
        )
    }
    
    func testEveryNthPage_2_DoNotIncludeFirst() throws {
        let descriptor: PDFPagesDescriptor = .every(nthPage: 2, includeFirst: false)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1]),
            .init(indexes: [1], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [0, 1, 2, 3, 4]),
            .init(indexes: [1, 3], isInclusive: true)
        )
    }
    
    func testRange() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1..<3)
        print(descriptor.verboseDescription)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [6], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8]),
            .init(indexes: [6, 7], isInclusive: true)
        )
    }
    
    func testClosedRange() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1...3)
        print(descriptor.verboseDescription)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [6], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [6, 7], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8]),
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8, 9]),
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
    }
    
    func testPartialRangeFrom() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: 1...)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [6], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8]),
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8, 9]),
            .init(indexes: [6, 7, 8, 9], isInclusive: true)
        )
    }
    
    func testPartialRangeUpTo() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: ..<2)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [1], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [5, 6], isInclusive: true)
        )
    }
    
    func testPartialRangeThrough() throws {
        let descriptor: PDFPagesDescriptor = .range(indexes: ...2)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [1], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [5, 6], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [5, 6, 7], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8]),
            .init(indexes: [5, 6, 7], isInclusive: true)
        )
    }
    
    func testOpenRange() throws {
        let descriptor: PDFPagesDescriptor = .openRange(startIndex: 1)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [1]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [6], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [6, 7], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8]),
            .init(indexes: [6, 7, 8], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8, 9]),
            .init(indexes: [6, 7, 8, 9], isInclusive: true)
        )
    }
    
    func testFirst() throws {
        let descriptor: PDFPagesDescriptor = .first(count: 2)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5]),
            .init(indexes: [5], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [5, 6], isInclusive: true)
        )
    }
    
    func testLast() throws {
        let descriptor: PDFPagesDescriptor = .last(count: 2)
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5]),
            .init(indexes: [5], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [5, 6], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7]),
            .init(indexes: [6, 7], isInclusive: true)
        )
    }
    
    func testPages() throws {
        let descriptor: PDFPagesDescriptor = .pages(indexes: [1, 3, 4])
        
        XCTAssertEqual(
            descriptor.apply(to: []),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5]),
            .init(indexes: [], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6]),
            .init(indexes: [6], isInclusive: false)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8, 9]),
            .init(indexes: [6, 8, 9], isInclusive: true)
        )
        
        XCTAssertEqual(
            descriptor.apply(to: [5, 6, 7, 8, 9, 10]),
            .init(indexes: [6, 8, 9], isInclusive: true)
        )
    }
}
