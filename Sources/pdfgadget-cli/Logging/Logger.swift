//
//  Logger.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if os(macOS)

import Foundation
import os.log

let logger = Logger(subsystem: "com.orchetect.PDFGadget", category: "CLI")

extension OSLogType: @retroactive CaseIterable {
    public static let allCases: [OSLogType] = [
        .debug, .info, .default, .error, .fault
    ]
}

extension OSLogType {
    public var name: String {
        switch self {
        case .debug: return "debug"
        case .info: return "info"
        case .default: return "default"
        case .error: return "error"
        case .fault: return "fault"
        default:
            assertionFailure("Unhandled OSLogType case: \(String(describing: self))")
            return String(describing: self)
        }
    }
    
    public init?(name: String) {
        guard let match = Self.allCases.first(where: { $0.name == name })
        else {
            assertionFailure("Unhandled OSLogType case: \(name)")
            return nil
        }
        
        self = match
    }
}

#endif
