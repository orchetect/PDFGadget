//
//  PDFPageArea Tests.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if canImport(PDFKit)

@testable import PDFGadgetLib
import Testing
import TestingExtensions

@Suite struct PDFPageAreaTests {
    @Test func rectForRotation_0degrees() throws {
        let pageBounds = CGRect(x: 0.0, y: 0.0, width: 612.0, height: 792.0) // original non-rotated coord space
        let angle: PDFPageRotation.Angle = ._0degrees
        
        #expect(
            PDFPageArea.rect(x: 153.0, y: 396.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 396.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 153.0, y: 198.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 198.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 198.0, width: 153.0, height: 198.0)
        )
        
        #expect(
            PDFPageArea.rect(x:   0.0, y: 396.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 396.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x:   0.0, y:   0.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y:   0.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y:   0.0, width: 306.0, height: 396.0)
        )
    }
    
    @Test func rectForRotation_90degrees() throws {
        let pageBounds = CGRect(x: 0.0, y: 0.0, width: 612.0, height: 792.0) // original non-rotated coord space
        let angle: PDFPageRotation.Angle = ._90degrees
        
        #expect(
            PDFPageArea.rect(x: 198.0, y: 306.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 306.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 198.0, y: 153.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 153.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 153.0, height: 198.0)
        )
        
        #expect(
            PDFPageArea.rect(x:   0.0, y: 306.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 306.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x:   0.0, y:   0.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y:   0.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 306.0, height: 396.0)
        )
    }
    
    @Test func rectForRotation_180degrees() throws {
        let pageBounds = CGRect(x: 0.0, y: 0.0, width: 612.0, height: 792.0) // original non-rotated coord space
        let angle: PDFPageRotation.Angle = ._180degrees
        
        #expect(
            PDFPageArea.rect(x: 153.0, y: 396.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 396.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 153.0, y: 198.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 198.0, width: 153.0, height: 198.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 396.0, width: 153.0, height: 198.0)
        )
        
        #expect(
            PDFPageArea.rect(x:   0.0, y: 396.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y: 396.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x:   0.0, y:   0.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 306.0, y:   0.0, width: 306.0, height: 396.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y: 396.0, width: 306.0, height: 396.0)
        )
    }
    
    @Test func rectForRotation_270degrees() throws {
        let pageBounds = CGRect(x: 0.0, y: 0.0, width: 612.0, height: 792.0) // original non-rotated coord space
        let angle: PDFPageRotation.Angle = ._270degrees
        
        #expect(
            PDFPageArea.rect(x: 198.0, y: 306.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 306.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 198.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 198.0, y: 153.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 396.0, width: 153.0, height: 198.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 153.0, width: 198.0, height: 153.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 153.0, y: 198.0, width: 153.0, height: 198.0)
        )
        
        #expect(
            PDFPageArea.rect(x:   0.0, y: 306.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y: 306.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x: 306.0, y:   0.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x:   0.0, y:   0.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y: 396.0, width: 306.0, height: 396.0)
        )
        #expect(
            PDFPageArea.rect(x: 396.0, y:   0.0, width: 396.0, height: 306.0).rect(for: pageBounds, rotation: angle)
                == CGRect(x:   0.0, y:   0.0, width: 306.0, height: 396.0)
        )
    }
}

#endif
