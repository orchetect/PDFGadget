//
//  FileLogHandler.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import Logging

struct FileHandlerOutputStream: TextOutputStream {
    enum FileHandlerOutputStream: Error {
        case couldNotCreateFile
    }

    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(localFile url: URL, encoding: String.Encoding = .utf8) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            else {
                throw FileHandlerOutputStream.couldNotCreateFile
            }
        }

        let fileHandle = try FileHandle(forWritingTo: url)
        fileHandle.seekToEndOfFile()
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

public struct FileLogHandler: LogHandler {
    private let stream: TextOutputStream
    private var label: String

    public var logLevel: Logger.Level = .info
    public var metadata = Logger.Metadata() {
        didSet {
            prettyMetadata = prettify(metadata)
        }
    }

    private var prettyMetadata: String?

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    public init(label: String, localFile url: URL) throws {
        self.label = label
        stream = try FileHandlerOutputStream(localFile: url)
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
        let prettyMetadata = metadata?.isEmpty ?? true
            ? prettyMetadata
            : prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        var stream = stream
        stream.write(
            "\(timestamp()) \(level) \(label) :\(prettyMetadata.map { " \($0)" } ?? "") \(message)\n"
        )
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                guard let addr = $0.baseAddress else { return "" }
                return String(cString: addr)
            }
        }
    }
}
