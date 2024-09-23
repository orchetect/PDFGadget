//
//  PDFGadgetCLI.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if os(macOS)

import Foundation
import ArgumentParser
import os.log
/* private */ import OTCore
import PDFGadgetLib

struct PDFGadgetCLI: ParsableCommand {
    // MARK: - Config
    
    static var configuration = CommandConfiguration(
        abstract: "PDF processing utilities.",
        discussion: "https://github.com/orchetect/PDFGadget",
        version: "0.1.1"
    )
    
    // MARK: - Arguments
    
    @Option(
        name: [.customLong("source"), .customShort("s")],
        parsing: .upToNextOption, // allows multiple values
        help: "One or more input PDF file(s).",
        transform: URL.init(fileURLWithPath:)
    )
    var source: [URL]
    
    @Option(
        name: [.customLong("destination"), .customShort("d")],
        help: "Output directory. Defaults to same director as first input file.",
        transform: URL.init(fileURLWithPath:)
    )
    var outputDir: URL?
    
    @Option(
        help: ArgumentHelp(
            "Log level.",
            valueName: OSLogType.allCases.map { $0.name }.joined(separator: ", ")
        )
    )
    var logLevel: OSLogType = .info
    
    @Flag(name: [.customLong("quiet")], help: "Disable log.")
    var logQuiet = false
    
    @Option(
        name: [.customLong("operations"), .customShort("o")],
        parsing: .upToNextOption, // allows multiple values
        help: "PDF editing operations."
    )
    var operations: [PDFOperation]
    
    // MARK: - Protocol Method Implementations
    
    mutating func validate() throws {
        #warning("> additional validation here")
    }
    
    mutating func run() throws {
        let settings: PDFGadget.Settings
        
        do {
            settings = try PDFGadget.Settings(
                sourcePDFs: source,
                outputDir: outputDir,
                operations: operations,
                savePDFs: true
                // ...
            )
        } catch let PDFGadgetError.validationError(error) {
            throw ValidationError(error)
        }
        
        try PDFGadget().run(using: settings)
    }
}

#endif
