//
//  ConsoleLogHandler.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if os(macOS)

import Foundation
import Logging

public struct ConsoleLogHandler: LogHandler {
    private let label: String

    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]

    public init(label: String) {
        self.label = label
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        if level == .info {
            print("\(message)")
        } else {
            print("\(level.rawValue.uppercased()): \(message)")
        }
    }
}

#endif
