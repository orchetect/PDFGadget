//
//  PDFPageSet Tests.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import XCTest
@testable import PDFTool

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
}
