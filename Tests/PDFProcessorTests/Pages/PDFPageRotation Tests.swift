//
//  PDFPageRotation Tests.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

@testable import PDFProcessor
import Testing
import TestingExtensions

@Suite struct PDFPageRotationTests {
    @Test func angleDegrees() throws {
        #expect(PDFPageRotation.Angle._0degrees.degrees == 0)
        #expect(PDFPageRotation.Angle._90degrees.degrees == 90)
        #expect(PDFPageRotation.Angle._180degrees.degrees == 180)
        #expect(PDFPageRotation.Angle._270degrees.degrees == 270)
    }
    
    @Test func angleInit() throws {
        // in spec
        #expect(PDFPageRotation.Angle(degrees: 0) == ._0degrees)
        #expect(PDFPageRotation.Angle(degrees: 90) == ._90degrees)
        #expect(PDFPageRotation.Angle(degrees: 180) == ._180degrees)
        #expect(PDFPageRotation.Angle(degrees: 270) == ._270degrees)
        
        // wrapping positive
        #expect(PDFPageRotation.Angle(degrees: 360) == ._0degrees)
        #expect(PDFPageRotation.Angle(degrees: 360 + 90) == ._90degrees)
        #expect(PDFPageRotation.Angle(degrees: 360 + 360 + 90) == ._90degrees)
        
        // wrapping negative
        #expect(PDFPageRotation.Angle(degrees: 360 - 90) == ._270degrees)
        #expect(PDFPageRotation.Angle(degrees: 360 - 360 - 90) == ._270degrees)
    }
    
    /// Test degrees that are not multiples of 90
    @Test func angleInitInvalid() throws {
        #expect(PDFPageRotation.Angle(degrees: 1) == nil)
        #expect(PDFPageRotation.Angle(degrees: 89) == nil)
        #expect(PDFPageRotation.Angle(degrees: 91) == nil)
        #expect(PDFPageRotation.Angle(degrees: 179) == nil)
        #expect(PDFPageRotation.Angle(degrees: 181) == nil)
        #expect(PDFPageRotation.Angle(degrees: 269) == nil)
        #expect(PDFPageRotation.Angle(degrees: 271) == nil)
        #expect(PDFPageRotation.Angle(degrees: 359) == nil)
    }
    
    @Test func angleMath() throws {
        let _0 = PDFPageRotation.Angle._0degrees
        let _90 = PDFPageRotation.Angle._90degrees
        let _180 = PDFPageRotation.Angle._180degrees
        let _270 = PDFPageRotation.Angle._270degrees
        
        #expect(_0 + _0 == _0)
        #expect(_0 + _90 == _90)
        #expect(_90 + _90 == _180)
        #expect(_90 + _180 == _270)
        #expect(_180 + _90 == _270)
        #expect(_180 + _180 == _0)
        #expect(_270 + _90 == _0)
        #expect(_270 + _180 == _90)
        #expect(_270 + _270 == _180)
        
        #expect(_0 - _0 == _0)
        #expect(_0 - _90 == _270)
        #expect(_90 - _90 == _0)
        #expect(_90 - _180 == _270)
        #expect(_180 - _90 == _90)
        #expect(_180 - _180 == _0)
        #expect(_270 - _90 == _180)
        #expect(_270 - _180 == _90)
        #expect(_270 - _270 == _0)
    }
}

#endif
