//
//  PDFPageRotation Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import XCTest
@testable import PDFGadgetLib

final class PDFPageRotationTests: XCTestCase {
    func testAngleDegrees() throws {
        XCTAssertEqual(PDFPageRotation.Angle._0degrees.degrees, 0)
        XCTAssertEqual(PDFPageRotation.Angle._90degrees.degrees, 90)
        XCTAssertEqual(PDFPageRotation.Angle._180degrees.degrees, 180)
        XCTAssertEqual(PDFPageRotation.Angle._270degrees.degrees, 270)
    }
    
    func testAngleInit() throws {
        // in spec
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 0), ._0degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 90), ._90degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 180), ._180degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 270), ._270degrees)
        
        // wrapping positive
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 360), ._0degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 360 + 90), ._90degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 360 + 360 + 90), ._90degrees)
        
        // wrapping negative
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 360 - 90), ._270degrees)
        XCTAssertEqual(PDFPageRotation.Angle(degrees: 360 - 360 - 90), ._270degrees)
    }
    
    /// Test degrees that are not multiples of 90
    func testAngleInitInvalid() throws {
        XCTAssertNil(PDFPageRotation.Angle(degrees: 1))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 89))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 91))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 179))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 181))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 269))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 271))
        XCTAssertNil(PDFPageRotation.Angle(degrees: 359))
    }
    
    func testAngleMath() throws {
        let _0 = PDFPageRotation.Angle._0degrees
        let _90 = PDFPageRotation.Angle._90degrees
        let _180 = PDFPageRotation.Angle._180degrees
        let _270 = PDFPageRotation.Angle._270degrees
        
        XCTAssertEqual(_0 + _0, _0)
        XCTAssertEqual(_0 + _90, _90)
        XCTAssertEqual(_90 + _90, _180)
        XCTAssertEqual(_90 + _180, _270)
        XCTAssertEqual(_180 + _90, _270)
        XCTAssertEqual(_180 + _180, _0)
        XCTAssertEqual(_270 + _90, _0)
        XCTAssertEqual(_270 + _180, _90)
        XCTAssertEqual(_270 + _270, _180)
        
        XCTAssertEqual(_0 - _0, _0)
        XCTAssertEqual(_0 - _90, _270)
        XCTAssertEqual(_90 - _90, _0)
        XCTAssertEqual(_90 - _180, _270)
        XCTAssertEqual(_180 - _90, _90)
        XCTAssertEqual(_180 - _180, _0)
        XCTAssertEqual(_270 - _90, _180)
        XCTAssertEqual(_270 - _180, _90)
        XCTAssertEqual(_270 - _270, _0)
    }
}
