//
//  main.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  Licensed under MIT License
//

import PDFGadgetLib

func main() {
    do {
        var command = try PDFGadgetCLI.parseAsRoot()
        try command.run()
    } catch {
        PDFGadgetCLI.exit(withError: error)
    }
}

main()
