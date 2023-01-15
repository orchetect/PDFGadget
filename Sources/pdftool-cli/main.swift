//
//  main.swift
//  PDFTool • https://github.com/orchetect/PDFTool
//  Licensed under MIT License
//

import PDFToolLib

func main() {
    do {
        var command = try PDFToolCLI.parseAsRoot()
        try command.run()
    } catch {
        PDFToolCLI.exit(withError: error)
    }
}

main()
