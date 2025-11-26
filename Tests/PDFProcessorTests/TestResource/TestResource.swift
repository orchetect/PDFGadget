//
//  TestResource.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation
import Testing
import TestingExtensions

// NOTE: DO NOT name any folders "Resources". Xcode will fail to build iOS targets.

// MARK: - Constants

/// Resources files on disk used for unit testing.
extension TestResource {
    static let pdf1page = TestResource.File(
        name: "1Page", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf2pages = TestResource.File(
        name: "2Pages", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf5pages = TestResource.File(
        name: "5Pages", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let pdf1page_withAttributes_withAnnotations = TestResource.File(
        name: "1Page-WithAttributes-WithAnnotations", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let loremIpsum = TestResource.File(
        name: "LoremIpsum", ext: "pdf", subFolder: "PDF Files"
    )
    
    static let permissions = TestResource.File(
        name: "Permissions", ext: "pdf", subFolder: "PDF Files"
    )
}
