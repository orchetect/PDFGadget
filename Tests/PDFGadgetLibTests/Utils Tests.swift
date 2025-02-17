//
//  Utils Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import CoreGraphics
@testable import PDFGadgetLib
import Testing

@Suite struct CGRectTests {
    // MARK: - Absolute
    
    @Test func testRotate90Degrees_ZeroOrigin_CommonOrigin() {
        let area = CGRect(x: 0, y: 0, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect.rotate90Degrees(within: area, isAbsolute: true)
        
        #expect(newRect.origin.x == 4.0)
        #expect(newRect.origin.y == 1.0)
        #expect(newRect.width == 7.0)
        #expect(newRect.height == 6.0)
    }
    
    @Test func testRotate90Degrees_ZeroOrigin_Absolute_360() {
        let area = CGRect(x: 0, y: 0, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
        
        #expect(newRect.origin.x == rect.origin.x)
        #expect(newRect.origin.y == rect.origin.y)
        #expect(newRect.width == rect.width)
        #expect(newRect.height == rect.height)
    }
    
    @Test func testRotate90Degrees_NonZeroOrigin_CommonOrigin() {
        let ox: CGFloat = 2
        let oy: CGFloat = 6
        let area = CGRect(x: ox, y: oy, width: 10, height: 13)
        let rect = CGRect(x: ox + 3, y: oy + 4, width: 6, height: 7)
        
        let newRect = rect.rotate90Degrees(within: area, isAbsolute: true)
        
        #expect(newRect.origin.x == oy + 4.0)
        #expect(newRect.origin.y == ox + 5.0)
        #expect(newRect.width == 7.0)
        #expect(newRect.height == 6.0)
    }
    
    @Test func testRotate90Degrees_NonZeroOrigin_Absolute_360() {
        let ox: CGFloat = 2
        let oy: CGFloat = 6
        let area = CGRect(x: ox, y: oy, width: 10, height: 13)
        let rect = CGRect(x: ox + 3, y: oy + 4, width: 6, height: 7)
        
        let newRect = rect
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
            .rotate90Degrees(within: area, isAbsolute: true)
        
        #expect(newRect.origin.x == rect.origin.x)
        #expect(newRect.origin.y == rect.origin.y)
        #expect(newRect.width == rect.width)
        #expect(newRect.height == rect.height)
    }
    
    // MARK: - Relative
    
    @Test func testRotate90Degrees_ZeroOrigin_Relative() {
        let area = CGRect(x: 0, y: 0, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect.rotate90Degrees(within: area, isAbsolute: false)
        
        #expect(newRect.origin.x == 4.0)
        #expect(newRect.origin.y == 1.0)
        #expect(newRect.width == 7.0)
        #expect(newRect.height == 6.0)
    }
    
    @Test func testRotate90Degrees_ZeroOrigin_Relative_360() {
        let area = CGRect(x: 0, y: 0, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
        
        #expect(newRect.origin.x == rect.origin.x)
        #expect(newRect.origin.y == rect.origin.y)
        #expect(newRect.width == rect.width)
        #expect(newRect.height == rect.height)
    }
    
    @Test func testRotate90Degrees_NonZeroOrigin_Relative() {
        let ox: CGFloat = 2
        let oy: CGFloat = 6
        let area = CGRect(x: ox, y: oy, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect.rotate90Degrees(within: area, isAbsolute: false)
        
        #expect(newRect.origin.x == oy + 4.0)
        #expect(newRect.origin.y == ox + 5.0)
        #expect(newRect.width == 7.0)
        #expect(newRect.height == 6.0)
    }
    
    @Test func testRotate90Degrees_NonZeroOrigin_Relative_360() {
        let ox: CGFloat = 2
        let oy: CGFloat = 6
        let area = CGRect(x: ox, y: oy, width: 10, height: 13)
        let rect = CGRect(x: 3, y: 4, width: 6, height: 7)
        
        let newRect = rect
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
            .rotate90Degrees(within: area, isAbsolute: false)
        
        #expect(newRect.origin.x == rect.origin.x)
        #expect(newRect.origin.y == rect.origin.y)
        #expect(newRect.width == rect.width)
        #expect(newRect.height == rect.height)
    }
}
