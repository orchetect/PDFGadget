//
//  PDFToolCLI.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import Foundation
import ArgumentParser
import Logging
import PDFToolLib

struct PDFToolCLI: ParsableCommand {
    // MARK: - Config
    
    static var configuration = CommandConfiguration(
        abstract: "PDF processing utilities.",
        discussion: "https://github.com/orchetect/PDFTool",
        version: "0.1.0"
    )
    
    // MARK: - Arguments
    
    @Argument(
        help: "Input PDF file(s). Can be specified more than once for multiple input files.",
        transform: URL.init(fileURLWithPath:)
    )
    var source: [URL]
    
    @Argument(
        help: "Output directory. Defaults to same director as first input file.",
        transform: URL.init(fileURLWithPath:)
    )
    var outputDir: URL?
    
    @Option(
        help: ArgumentHelp(
            "Log level.",
            valueName: Logger.Level.allCases.map { $0.rawValue }.joined(separator: ", ")
        )
    )
    var logLevel: Logger.Level = .info
    
    @Flag(name: [.customLong("quiet")], help: "Disable log.")
    var logQuiet = false
    
    // MARK: - Protocol Method Implementations
    
    mutating func validate() throws {
        #warning("> additional validation here")
    }
    
    mutating func run() throws {
        initLogging(logLevel: logQuiet ? nil : logLevel, logFile: nil)
        
        let settings: PDFTool.Settings
        
        do {
            settings = try PDFTool.Settings(
                sourcePDFs: source,
                outputDir: outputDir,
                operations: [], // TODO: implement
                outputBaseFileNameWithoutExtension: nil // TODO: implement
                // ...
            )
        } catch let PDFToolError.validationError(error) {
            throw ValidationError(error)
        }
        
        try PDFTool.process(settings: settings)
    }
}

// MARK: Helpers

extension PDFToolCLI {
    private func initLogging(logLevel: Logger.Level?, logFile: URL?) {
        LoggingSystem.bootstrap { label in
            guard let logLevel = logLevel else {
                return SwiftLogNoOpLogHandler()
            }

            var logHandlers: [LogHandler] = [
                ConsoleLogHandler(label: label)
            ]

            if let logFile = logFile {
                do {
                    logHandlers.append(try FileLogHandler(label: label, localFile: logFile))
                } catch {
                    print(
                        "Cannot write to log file \(logFile.lastPathComponent.quoted):"
                            + " \(error.localizedDescription)"
                    )
                }
            }

            for i in 0 ..< logHandlers.count {
                logHandlers[i].logLevel = logLevel
            }

            return MultiplexLogHandler(logHandlers)
        }
    }
}
