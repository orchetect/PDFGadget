//
//  PDFPagesDescriptor.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import OTCore

public enum PDFPagesDescriptor {
    /// Page number is explicitly an odd integer.
    case odd
    
    /// Page number is explicitly an even integer.
    case even
    
    /// Every n number of pages.
    case every(nthPage: Int, includeFirst: Bool)
    
    /// A defined range of pages.
    case range(indexes: any RangeExpression<Int>)
    
    /// An open-ended range of pages with a starting point.
    case openRange(startIndex: Int)
    
    /// First n number of pages.
    case first(pageCount: Int)
    
    /// Last n number of pages.
    case last(pageCount: Int)
    
    /// Individual pages.
    case pages(indexes: [Int])
}

extension PDFPagesDescriptor: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .odd:
            guard case .odd = rhs else { return false }
            return true
            
        case .even:
            guard case .even = rhs else { return false }
            return true
            
        case let .every(lhsnthPage, lhsincludeFirst):
            guard case let .every(rhsnthPage, rhsincludeFirst) = rhs else { return false }
            return lhsnthPage == rhsnthPage && lhsincludeFirst == rhsincludeFirst
            
        case let .range(lhsRange):
            guard case let .range(rhsRange) = rhs else { return false }
            let lhsBounds = lhsRange.getAbsoluteBounds()
            let rhsBounds = rhsRange.getAbsoluteBounds()
            return lhsBounds.min == rhsBounds.min && lhsBounds.max == rhsBounds.max
            
        case let .openRange(lhsOpenRange):
            guard case let .openRange(rhsOpenRange) = rhs else { return false }
            return lhsOpenRange == rhsOpenRange
            
        case let .first(lhspageCount):
            guard case let .first(rhspageCount) = rhs else { return false }
            return lhspageCount == rhspageCount
            
        case let .last(lhspageCount):
            guard case let .first(rhspageCount) = rhs else { return false }
            return lhspageCount == rhspageCount
            
        case let .pages(lhsArray):
            guard case let .pages(rhsArray) = rhs else { return false }
            return lhsArray == rhsArray
        }
    }
}

extension PDFPagesDescriptor: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .odd:
            hasher.combine(100000)
            
        case .even:
            hasher.combine(200000)
            
        case let .every(nthPage, includeFirst):
            hasher.combine(300000)
            hasher.combine(nthPage)
            hasher.combine(includeFirst ? 10000 : 0)
            
        case let .range(range):
            hasher.combine(400000)
            let bounds = range.getAbsoluteBounds()
            hasher.combine(bounds.min)
            hasher.combine(bounds.max)
            
        case let .openRange(startIndex):
            hasher.combine(500000)
            hasher.combine(startIndex)
            
        case let .first(pageCount):
            hasher.combine(600000)
            hasher.combine(pageCount)
            
        case let .last(pageCount):
            hasher.combine(700000)
            hasher.combine(pageCount)
            
        case let .pages(array):
            hasher.combine(800000)
            hasher.combine(array)
        }
    }
}

extension PDFPagesDescriptor {
    public var verboseDescription: String {
        switch self {
        case .odd:
            return "Odd pages"
            
        case .even:
            return "Even pages"
            
        case let .every(nthPage, includeFirst):
            // TODO: implement localized ordinal number string "1st page", "2nd page"
            return "Every \(nthPage) pages,\(includeFirst ? "" : " not") including the first page"
            
        case let .range(range):
            let bounds = range.getAbsoluteBounds()
            
            return "Page indexes \(bounds.min?.string ?? "")...\(bounds.max?.string ?? "")"
            
        case let .openRange(start):
            return "From page index \(start)"
            
        case let .first(pageCount):
            return "First \(pageCount) pages"
            
        case let .last(pageCount):
            return "Last \(pageCount) pages"
            
        case let .pages(intArray):
            return "Page indexes \(intArray.map { "\($0)" }.joined(separator: ", "))"
        }
    }
}

extension PDFPagesDescriptor {
    public struct ApplyResult: Equatable {
        let indexes: [Int]
        let isInclusive: Bool
    }
    
    public func apply(
        to pageNumbers: [Int],
        sort: Bool = true
    ) -> ApplyResult {
        var arrayIndices = Array(pageNumbers.indices)
        var isInclusive: Bool
        
        switch self {
        case .odd:
            isInclusive = arrayIndices.count > 0
            arrayIndices = arrayIndices.filter { $0 % 2 == 0 }
            
        case .even:
            isInclusive = arrayIndices.count > 1
            arrayIndices = arrayIndices.filter { $0 % 2 == 1 }
            
        case let .every(nthPage, includeFirst):
            guard nthPage > 0 else {
                isInclusive = true
                break
            }
            if includeFirst {
                isInclusive = arrayIndices.count >= 1
                arrayIndices = arrayIndices.filter { $0 % nthPage == 0 }
            } else {
                isInclusive = arrayIndices.count >= nthPage
                arrayIndices = arrayIndices.filter { ($0 - 1) % nthPage == 0 }
            }
            
        case let .range(range):
            isInclusive = range.isContainedWithin(values: arrayIndices)
            arrayIndices = arrayIndices.filter { range.contains($0) }
            
        case let .openRange(start):
            isInclusive = arrayIndices.contains(where: { (start...).contains($0) })
            arrayIndices = arrayIndices.filter { (start...).contains($0) }
            
        case let .first(pageCount):
            isInclusive = arrayIndices.count >= pageCount
            if isInclusive { // avoid crashes
                arrayIndices = Array(arrayIndices[0 ..< pageCount])
            } else {
                arrayIndices = Array(arrayIndices[0 ..< arrayIndices.count])
            }
            
        case let .last(pageCount):
            isInclusive = arrayIndices.count >= pageCount
            if isInclusive { // avoid crashes
                arrayIndices = arrayIndices.suffix(pageCount)
            } else {
                arrayIndices = Array(arrayIndices[0 ..< arrayIndices.count])
            }
            
        case let .pages(array):
            isInclusive = array.allSatisfy(arrayIndices.contains(_:))
            arrayIndices = arrayIndices.filter { array.contains($0) }
        }
        
        var indexNumbers = arrayIndices.map { pageNumbers[$0] }
        
        if sort {
            indexNumbers.sort()
        }
        return ApplyResult(indexes: indexNumbers, isInclusive: isInclusive)
    }
    
    public func containsSamePages(as other: Self) -> Bool {
        switch self {
        case let .pages(lhsArray):
            guard case let .pages(rhsArray) = other else { return false }
            return Set(lhsArray) == Set(rhsArray)
            
        default:
            return Set([self, other]).count == 1
        }
    }
}
