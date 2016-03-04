//
//  Plist.swift
//  PregnancyCalendar
//
//  Created by farestz on 29.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import Foundation

struct Plist {
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let fileName: String
    
    var sourcePath: String? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist") else { return .None }
        return path
    }
    
    var destinationPath: String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(fileName).plist")
    }
    
    init? (fileName: String) {
        self.fileName = fileName
        let fileManager = NSFileManager.defaultManager()
        guard let source = sourcePath else { return nil }
        guard let destination = destinationPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }
        
        if !fileManager.fileExistsAtPath(destination) {
            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. Error: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesFromPlistFile() -> NSDictionary? {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destinationPath!) {
            guard let dict = NSDictionary(contentsOfFile: destinationPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary? {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destinationPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destinationPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func addValuesToPlistFile(dictionary: NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destinationPath!) {
            if !dictionary.writeToFile(destinationPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}