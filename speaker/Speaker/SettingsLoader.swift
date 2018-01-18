//
//  SettingsLoader.swift
//  speaker
//
//  Created by UX Team Prague on 13.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import Cocoa

//Class for loading settings from plist file
class SettingsLoader: NSObject {
    
    private var path = ""
    private var plistSpecified = false
    private var plistSpecifiedExists = false

    init(plistPath: String?) {
       super.init()
        
        //plist specified
        if let plistPath = plistPath{
            
            plistSpecified = true
            
            //check if file exists
            if (!fileExists(path: plistPath)) {
                path = Settings.DefaultValue.defaultPlistPath
                NSLog("Settings plist file: \"%@\" does not exist.", plistPath)
            } else {
                plistSpecifiedExists = true
                path = plistPath
            }
        //plist not specified, use default path
        } else {
            path = Settings.DefaultValue.defaultPlistPath
        }
        
    }
    
    //load settings from plist file into Settings object
    func loadSettings() -> Settings {
        let settings = Settings()
        
        var dict: NSDictionary?
        
        NSLog("Using settings plist file: \"%@\"", path)
        
        //Load plist into dictionary
        dict = NSDictionary(contentsOfFile: path)
        
        //Parse dictionary
        if let settingsDict = dict as? Dictionary<String, AnyObject> {
            settings.volume = settingsDict["Volume"] as? Float ?? Settings.DefaultValue.volume
            settings.rate = settingsDict["Rate"] as? Float ?? Settings.DefaultValue.rate
            
            let voiceName = settingsDict["Voice"] as? String ?? ""
            if (voiceName != "") {
                settings.voice = NSSpeechSynthesizer.VoiceName(rawValue: voiceName)
            } else {
                settings.voice = nil
            }
            
            settings.rss = URL(string: settingsDict["RSS"] as? String ?? Settings.DefaultValue.rss)
            settings.port = settingsDict["Port"] as? Port ?? Settings.DefaultValue.port
            settings.useJingles = settingsDict["Jingles"] as? Bool ?? Settings.DefaultValue.useJingles
            
        //Set default values if plist could not be parsed
        } else {
            var usingDefaultPlist = true
            
            //Failed to parse specified plist
            if (plistSpecified && plistSpecifiedExists) {
                NSLog("Settings plist file: \"%@\" could not be parsed, using default settings.", path)
                usingDefaultPlist = false
                
            //Tried to use default plist which does not exist
            } else if (!fileExists(path: path)){
                NSLog("Default settings plist file: \"%@\" does not exist, using default settings.", path)
                
            //Tried to use default plist, which could not be parsed
            } else {
                NSLog("Default settings plist file: \"%@\" could not be parsed, using default settings.", path)
            }
            
            //Set default values
            settings.volume = Settings.DefaultValue.volume
            settings.rate = Settings.DefaultValue.rate
            settings.voice = Settings.DefaultValue.voice
            settings.rss = URL(string: Settings.DefaultValue.rss)
            settings.port = Settings.DefaultValue.port
            settings.useJingles = Settings.DefaultValue.useJingles
            
            //Default plist does not exist or could not be parsed, create one
            if (usingDefaultPlist) {
                _ = SettingsLoader.saveSettings(settings: settings)
            }
        }
        
        return settings
    }
    
    //Check if file exists
    private func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    //Save dictionary with current settings into default plist
    static func saveSettings(settings: Settings, path: String = Settings.DefaultValue.defaultPlistPath) -> Bool {
        let dict = settings.createDictionary()
        if (!NSDictionary(dictionary: dict).write(toFile: path, atomically: false)) {
            return false
        }
        return true
    }
}
