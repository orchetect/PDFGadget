//
//  PDFOperation Commands.swift
//  PDFGadget • https://github.com/orchetect/PDFGadget
//  © 2023-2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import ArgumentParser
import Foundation
import PDFGadgetLib
internal import OTCore

// We can safely use `@retroactive` since we are the owner of this type in the package.
extension PDFOperation: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        // ⚠️ NOTE: THIS IS A WORK IN PROGRESS
        
        // ideas for each operation's arguments:
        //   - JSON ie: {"from":0,"to":1}
        //   - like a method call ie: filterPages(from:0,to:1)
        
        guard let id = Identifier.allCases.first(where: {
            argument.hasPrefix("\($0):") || argument == $0.rawValue
        }) else { return nil }
        let rawParams = String(argument.dropFirst(id.rawValue.count + 1))
        
        print(id.rawValue, "with body:", String(rawParams).quoted)
        
        switch id {
        case .newFile:
            self = .newFile
        case .cloneFile:
            fatalError("Not yet implemented.")
//            self = .cloneFile(file: )
        case .filterFiles:
            fatalError("Not yet implemented.")
        case .mergeFiles:
            fatalError("Not yet implemented.")
        case .splitFile:
            fatalError("Not yet implemented.")
        case .setFilename:
            fatalError("Not yet implemented.")
        case .removeFileAttributes:
            fatalError("Not yet implemented.")
        case .setFileAttribute:
            fatalError("Not yet implemented.")
        case .filterPages:
            fatalError("Not yet implemented.")
        case .copyPages:
            fatalError("Not yet implemented.")
        case .movePages:
            fatalError("Not yet implemented.")
        case .replacePages:
            fatalError("Not yet implemented.")
        case .reversePageOrder:
            fatalError("Not yet implemented.")
        case .rotatePages:
            fatalError("Not yet implemented.")
        case .filterAnnotations:
            fatalError("Not yet implemented.")
        }
    }
    
    private enum Identifier: String, CaseIterable {
        case newFile
        case cloneFile
        case filterFiles
        case mergeFiles
        case splitFile
        case setFilename
        case removeFileAttributes
        case setFileAttribute
        case filterPages
        case copyPages
        case movePages
        case replacePages
        case reversePageOrder
        case rotatePages
        case filterAnnotations
    }
}

// extension PDFGadgetCLI {
//    struct Foo: ExpressibleByArgument {
//        init?(argument: String) {
//            #warning("> run sub-parser")
//        }
//
//
//    }
//    struct OperationsBuilder: ParsableArguments {
//        internal var wrapper: Operations = .init()
//
//        init() { }
//
//        init(_ string: String) {
//            #warning("> run sub-parser")
//        }
//
//        internal struct Operations: Codable {
//            var operations: [PDFOperation]
//
//            init(operations: [PDFOperation] = []) {
//                self.operations = operations
//            }
//
//            func encode(to encoder: Encoder) throws {
//                // we're not actually implementing Codable, it's just to satisfy ParsableArguments
//            }
//
//            init(from decoder: Decoder) throws {
//                // we're not actually implementing Codable, it's just to satisfy ParsableArguments
//                self.init()
//            }
//        }
//    }
//
//    struct NewFile: ParsableCommand {
//        static var configuration = CommandConfiguration(commandName: "newfile")
//
//        @OptionGroup var builder: OperationsBuilder
//
//        mutating func run() {
//            builder.wrapper.operations.append(.newFile)
//        }
//    }
// }

#endif
