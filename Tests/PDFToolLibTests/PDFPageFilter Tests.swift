//
//  PDFPageFilter Tests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib

final class PDFPageFilterTests: XCTestCase {
    func testAll() throws {
        let filter: PDFPageFilter = .all
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, true)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [1, 3, 4, 5])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testInclude_Odd() throws {
        let filter: PDFPageFilter = .only([.odd])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [1, 4])
            XCTAssertEqual(filtered.excluded, [3, 5])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testInclude_Even() throws {
        let filter: PDFPageFilter = .only([.even])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [3, 5])
            XCTAssertEqual(filtered.excluded, [1, 4])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testInclude_Multiple_isInclusive() throws {
        let filter: PDFPageFilter = .only([
            .pages(indexes: [0]),
            .range(indexes: 2...3)
        ])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5, 6])
            XCTAssertEqual(filtered.included, [1, 4, 5])
            XCTAssertEqual(filtered.excluded, [3, 6])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testInclude_Multiple_isNotInclusive_FirstNotInclusive() throws {
        let filter: PDFPageFilter = .only([
            .pages(indexes: [4]),
            .range(indexes: 2...3)
        ])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [4, 5])
            XCTAssertEqual(filtered.excluded, [1, 3])
            XCTAssertEqual(filtered.isInclusive, false)
        }
    }
    
    func testInclude_Multiple_isNotInclusive_LastNotInclusive() throws {
        let filter: PDFPageFilter = .only([
            .pages(indexes: [0]),
            .range(indexes: 2...3)
        ])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4])
            XCTAssertEqual(filtered.included, [1, 4])
            XCTAssertEqual(filtered.excluded, [3])
            XCTAssertEqual(filtered.isInclusive, false)
        }
    }
    
    func testExclude_Odd() throws {
        let filter: PDFPageFilter = .drop([.odd])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [3, 5])
            XCTAssertEqual(filtered.excluded, [1, 4])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testExclude_Even() throws {
        let filter: PDFPageFilter = .drop([.even])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5])
            XCTAssertEqual(filtered.included, [1, 4])
            XCTAssertEqual(filtered.excluded, [3, 5])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
    
    func testExclude_Multiple_isInclusive() throws {
        let filter: PDFPageFilter = .drop([
            .pages(indexes: [0]),
            .range(indexes: 2...3)
        ])
        
        do {
            let filtered = filter.apply(to: [])
            XCTAssertEqual(filtered.included, [])
            XCTAssertEqual(filtered.excluded, [])
            XCTAssertEqual(filtered.isInclusive, false)
        }
        
        do {
            let filtered = filter.apply(to: [1, 3, 4, 5, 6])
            XCTAssertEqual(filtered.included, [3, 6])
            XCTAssertEqual(filtered.excluded, [1, 4, 5])
            XCTAssertEqual(filtered.isInclusive, true)
        }
    }
}
