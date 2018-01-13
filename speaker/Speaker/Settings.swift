//
//  Settings.swift
//  speaker
//
//  Created by Tomas Cerny on 07.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import Cocoa

//Read and write synthetizer's settings into plist
class Settings: NSObject {
    
    //Default values
    private struct DefaultValue {
        static let volume : Float = 1.0
        static let rate : Float = 200
        static let voice : NSSpeechSynthesizer.VoiceName? = nil
        static let rss = ""
        static let port : Port = 8080
        static let useJingles = false
        static let defaultPlistPath = "defaultSettings.plist"
    }

    var volume: Float!
    var rate: Float!
    var voice: NSSpeechSynthesizer.VoiceName?
    var rss: URL?
    var port: Port!
    var useJingles: Bool!
    
    init(plistPath: String?) {
        super.init()
        
        var dict: NSDictionary?
        
        var path = ""
        if (plistPath != nil) {
            if (!fileExists(path: plistPath!)) {
                path = DefaultValue.defaultPlistPath
                NSLog("Settings plist file: \"%@\" does not exist.", plistPath!)
            } else {
                path = plistPath!
            }
        } else {
            path = DefaultValue.defaultPlistPath
        }
        
        NSLog("Using settings plist file: \"%@\"", path)
        
        //Load plist into dictionary
        dict = NSDictionary(contentsOfFile: path)
        
        //Parse dictionary
        if let settings = dict as? Dictionary<String, AnyObject> {
            volume = settings["Volume"] as? Float ?? DefaultValue.volume
            rate = settings["Rate"] as? Float ?? DefaultValue.rate
            
            let voiceName = settings["Voice"] as? String ?? ""
            if (voiceName != "") {
                voice = NSSpeechSynthesizer.VoiceName(rawValue: voiceName)
            } else {
                voice = nil
            }
            
            rss = URL(string: settings["RSS"] as? String ?? DefaultValue.rss)
            port = settings["Port"] as? Port ?? DefaultValue.port
            useJingles = settings["Jingles"] as? Bool ?? DefaultValue.useJingles
        
        //Set default values if plist could not be parsed
        } else {
            var usingDefaultPlist = true
            if ((plistPath != nil) && (plistPath! == path)) {
                NSLog("Settings plist file: \"%@\" could not be parsed, using default settings.", plistPath!)
                usingDefaultPlist = false
            } else if (!fileExists(path: path)){
                NSLog("Default settings plist file: \"%@\" does not exist, using default settings.", path)
            } else {
                NSLog("Default settings plist file: \"%@\" could not be parsed, using default settings.", path)
            }
            
            volume = DefaultValue.volume
            rate = DefaultValue.rate
            voice = DefaultValue.voice
            rss = URL(string: DefaultValue.rss)
            port = DefaultValue.port
            useJingles = DefaultValue.useJingles
            
            if (usingDefaultPlist) {
                _ = saveSettings()
            }
        }
    }
    
    private func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    //Create dictionary with current settings to be written into plist
    private func createDictionary() -> Dictionary<String, AnyObject> {
        return ["Volume": volume as NSNumber, "Voice": NSString(string: (voice?.rawValue ?? "")) , "Rate": rate as NSNumber, "RSS": NSString(string: (rss?.absoluteString ?? "")), "Port": port as NSNumber, "Jingles": useJingles as NSNumber]
    }
    
    //Save dictionary with current settings into default plist
    func saveSettings(path: String = DefaultValue.defaultPlistPath) -> Bool {
        let dict = createDictionary()
        if (!NSDictionary(dictionary: dict).write(toFile: path, atomically: false)) {
            return false
        }
        return true
    }
}
