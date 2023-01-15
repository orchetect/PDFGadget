//
//  PDFPageSet.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation

public enum PDFPageSet {
    /// Page number is explicitly an odd integer.
    case odd
    
    /// Page number is explicitly an even integer.
    case even
    
    /// Every n number of pages.
    case every(nthPage: Int)
    
    /// A defined range of pages.
    case range(ClosedRange<Int>)
    
    /// An open-ended range of pages with a starting point.
    case openRange(start: Int)
    
    /// Individual pages.
    case pages([Int])
}

extension PDFPageSet: Equatable {
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        switch lhs {
//        case .odd:
//            guard case .odd = rhs else { return false }
//            return true
//
//        case .even:
//            guard case .even = rhs else { return false }
//            return true
//
//        case let .every(lhsNthPage):
//            guard case let .every(rhsNthPage) = rhs else { return false }
//            return lhsNthPage == rhsNthPage
//
//        case let .range(lhsClosedRange):
//            guard case let .range(rhsClosedRange) = rhs else { return false }
//            return lhsClosedRange == rhsClosedRange
//
//        case let .openRange(lhsOpenRange):
//            guard case let .openRange(rhsOpenRange) = rhs else { return false }
//            return lhsOpenRange == rhsOpenRange
//
//        case let .pages(lhsArray):
//            guard case let .pages(rhsArray) = rhs else { return false }
//            return lhsArray == rhsArray
//        }
//    }
}

extension PDFPageSet: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(self)
//        switch self {
//        case .odd:
//            hasher.combine(self)
//        case .even:
//            hasher.combine(self)
//        case .every(let nthPage):
//            hasher.combine(self)
//        case .range(let closedRange):
//            hasher.combine(self)
//        case .openRange(let partialRangeFrom):
//            hasher.combine(self)
//        case .pages(let array):
//            hasher.combine(self)
//        }
//    }
}

extension PDFPageSet {
    public func apply(to pageNumbers: [Int], explicit: Bool) -> [Int] {
        var pageNumbers = pageNumbers
        
        switch self {
        case .odd:
            pageNumbers = pageNumbers.filter { $0 % 2 == 0 }
            
        case .even:
            pageNumbers = pageNumbers.filter { $0 % 2 == 1 }
            
        case let .every(nthPage):
            guard nthPage > 0 else { return pageNumbers }
            pageNumbers = pageNumbers.filter { $0 % nthPage == 0 }
            
        case let .range(closedRange):
            pageNumbers = pageNumbers.filter { closedRange.contains($0) }
            
        case let .openRange(start):
            pageNumbers = pageNumbers.filter { (start...).contains($0) }
            
        case let .pages(array):
            pageNumbers = pageNumbers.filter { array.contains($0) }
        }
        
        pageNumbers.sort()
        return pageNumbers
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
