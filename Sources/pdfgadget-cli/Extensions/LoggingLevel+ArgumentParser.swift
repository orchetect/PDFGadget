//
//  LoggingLevel+ArgumentParser.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

#if os(macOS)

import ArgumentParser
import Logging

extension Logger.Level: @retroactive ExpressibleByArgument { }

#endif
