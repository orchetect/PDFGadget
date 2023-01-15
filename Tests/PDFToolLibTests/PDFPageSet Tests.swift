//
//  PDFPageSet Tests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFToolLib

final class PDFPageSetTests: XCTestCase {
    func testHashable() throws {
        var pageSets: Set<PDFPageSet> = []
        
        pageSets = [
            .odd,
            .odd,
            
            .even,
            .even,
            
            .every(nthPage: 1),
            .every(nthPage: 1),
            
            .every(nthPage: 2),
            .every(nthPage: 2),
            
            .range(1 ... 5),
            .range(1 ... 5),
            
            .range(1 ... 6),
            .range(1 ... 6),
            
            .openRange(start: 1),
            .openRange(start: 1),
            
            .openRange(start: 2),
            .openRange(start: 2),
            
            .pages([1, 2]),
            .pages([1, 2]),
            
            .pages([3, 4]),
            .pages([3, 4])
        ]
        
        XCTAssertEqual(pageSets.count, 10)
    }
    
    func testHashable_EdgeCases() throws {
        // .page() page order is an array, not a set.
        XCTAssertEqual(
            Set<PDFPageSet>([.pages([1, 2]), .pages([2, 1])]),
            [.pages([1, 2]), .pages([2, 1])]
        )
    }
    
    func testContainsSamePages() throws {
        func isSame(_ lhs: PDFPageSet, _ rhs: PDFPageSet? = nil) {
            let rhs = rhs ?? lhs
            XCTAssertTrue(lhs.containsSamePages(as: rhs),
            "\(lhs) is not the same as \(rhs)")
        }
        
        // baseline cases
        
        let sets = [PDFPageSet]([
            .odd,
            .even,
            .every(nthPage: 1),
            .range(1 ... 5),
            .openRange(start: 1),
            .pages([1, 2])
        ])
        
        sets.forEach { isSame($0) }
        
        // specific conditions
        
        isSame(.pages([1, 2]), .pages([2, 1]))
        
        // false conditions
        
        XCTAssertFalse(PDFPageSet.odd.containsSamePages(as: .even))
    }
}
