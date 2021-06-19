//
//  main.swift
//  pb - native clipboard inspection and filtering tool
//
//  Created by Roland Crosby on 6/19/21.
//

import Foundation
import AppKit.NSPasteboard
import ArgumentParser
import UniformTypeIdentifiers
import System

func pbDataConformingTo(typeName: String) -> (conformingType: NSPasteboard.PasteboardType, data: Data)? {
    let pb = NSPasteboard.general
    guard let desiredType = UTType(typeName) else {return nil}
    guard let items = pb.pasteboardItems else {return nil}
    for item in items {
        for foundType in item.types {
            guard let foundTypeUTI = UTType(foundType.rawValue) else {continue}
            if foundTypeUTI.conforms(to: desiredType) {
                guard let data = item.data(forType: foundType) else {return nil}
                return (conformingType: foundType, data: data)
            }
        }
    }
    return nil
}

func runFilter(typeName: String) throws {
    if let conformingResult = pbDataConformingTo(typeName: typeName) {
        print("\(conformingResult.conformingType.rawValue) conforms to \(typeName); replacing clipboard contents")
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setData(conformingResult.data, forType: conformingResult.conformingType)
    } else {
        print("No data conforming to \(typeName) found on clipboard")
        throw ExitCode.failure
    }
}

struct PB: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Inspect and manipulate the macOS clipboard",
        subcommands: [Types.self, Filter.self, Image.self, Text.self])
}

struct Filter: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Filter the clipboard contents to a specified type")
    
    @Argument(help: "Type indicator to filter the clipboard to, such as `public.plain-text`")
    var desiredType: String
    
    func validate() throws {
        if UTType(desiredType) == nil {
            throw ValidationError("\(desiredType) is not a valid type indicator")
        }
    }
    
    mutating func run() throws {
        try runFilter(typeName: desiredType)
    }
}

struct Image: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Filter the clipboard contents to image data (shorthand for `pb filter public.image`)")
    
    mutating func run() throws {
        try runFilter(typeName: "public.image")
    }
}

struct Text: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Filter the clipboard contents to plain text data (shorthand for `pb filter public.plain-text`)")
    
    mutating func run() throws {
        try runFilter(typeName: "public.plain-text")
    }
}

struct Types: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "List the type names of the contents of the clipboard")
    
    mutating func run() {
        let pb = NSPasteboard.general
        guard let items = pb.pasteboardItems else {return}
        for item in items {
            for type in item.types {
                print(type.rawValue)
            }
        }
    }
}

PB.main()
