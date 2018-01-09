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
    }

    var volume: Float!
    var rate: Float!
    var voice: NSSpeechSynthesizer.VoiceName?
    var rss: URL?
    var port: Port!
    var useJingles: Bool!
    
    override init() {
        super.init()
        
        var dict: NSDictionary?
        
        let path = getPlistPath()
        
        //Load plist into dictionary
        dict = NSDictionary(contentsOfFile: path)
        
        //Parse dictionary
        if let settings = dict as? Dictionary<String, AnyObject> {
            volume = settings["Volume"] as? Float ?? DefaultValue.volume
            rate = settings["Rate"] as? Float ?? DefaultValue.rate
            voice = NSSpeechSynthesizer.VoiceName(rawValue: settings["Voice"] as? String ?? "")
            rss = URL(string: settings["RSS"] as? String ?? DefaultValue.rss)
            port = settings["Port"] as? Port ?? DefaultValue.port
            useJingles = settings["Jingles"] as? Bool ?? DefaultValue.useJingles
        
        //Set default values if plist could not be parsed
        } else {
            volume = DefaultValue.volume
            rate = DefaultValue.rate
            voice = DefaultValue.voice
            rss = URL(string: DefaultValue.rss)
            port = DefaultValue.port
            useJingles = DefaultValue.useJingles
        }
    }
    
    //Get path for Settings.plist
    private func getPlistPath() -> String {
        return FileManager.default.currentDirectoryPath.appendingPathComponent("Settings.plist")
    }
    
    //Create dictionary with current settings to be written into plist
    private func createDictionary() -> Dictionary<String, AnyObject> {
        return ["Volume": volume as NSNumber, "Voice": NSString(string: (voice?.rawValue ?? "")) , "Rate": rate as NSNumber, "RSS": NSString(string: (rss?.absoluteString ?? "")), "Port": rate as NSNumber, "Jingles": useJingles as NSNumber]
    }
    
    //Save dictionary with current settings into plist
    func saveSettings() -> Bool {
        let dict = createDictionary()
        if (!NSDictionary(dictionary: dict).write(toFile: getPlistPath(), atomically: false)) {
            return false
        }
        return true
    }
}
