//
//  AudioFile.swift
//  DW Speaker
//
//  Created by Andy Giefer on 16.08.23.
//
//
//import SwiftUI
//import UniformTypeIdentifiers
//
//struct AudioFile: FileDocument {
//    // tell the system we support only audio
//    static var readableContentTypes = [UTType.audio]
//
//    // by default our document is empty
//    var audioData: Data?
//
//    // a simple initializer that creates new, empty documents
//    init(data: Data) {
//        self.audioData = data
//    }
//
//    // this initializer loads data that has been saved previously
//    init(configuration: ReadConfiguration) throws {
//        if let data = configuration.file.regularFileContents {
//            audioData = data
//        }
//    }
//
//    // this will be called when the system wants to write our data to disk
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        if let data = audioData {
//            return FileWrapper(regularFileWithContents: data)
//        }
//        return FileWrapper.init()
//    }
//}
