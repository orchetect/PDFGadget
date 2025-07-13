//
//  LoggingLevel+ArgumentParser.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import ArgumentParser
import os.log

extension OSLogType: @retroactive ExpressibleByArgument { }

#endif
