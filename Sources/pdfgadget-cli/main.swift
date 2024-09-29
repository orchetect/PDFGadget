//
//  main.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

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

#endif
