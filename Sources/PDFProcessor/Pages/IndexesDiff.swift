//
//  IndexesDiff.swift
//  swift-pdf-processor • https://github.com/orchetect/swift-pdf-processor
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

public struct IndexesDiff {
    let original: [Int]
    
    public let included: [Int]
    public let excluded: [Int]
    
    /// `true` if the diff operation's conditions were within the original indexes' bounds.
    /// `false` if the result does not contain all expected results.
    public let isInclusive: Bool
    
    public init(original: [Int], included: [Int], excluded: [Int], isInclusive: Bool) {
        self.original = original
        self.included = included
        self.excluded = excluded
        self.isInclusive = isInclusive
    }
    
    public var isIdentical: Bool {
        included == original
    }
}

extension IndexesDiff: Equatable { }

extension IndexesDiff: Hashable { }

extension IndexesDiff: Sendable { }
