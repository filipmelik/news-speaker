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
    public struct DefaultValue {
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
    
    //Create dictionary with current settings to be written into plist
    func createDictionary() -> Dictionary<String, AnyObject> {
        return ["Volume": volume as NSNumber,
                "Voice": NSString(string: (voice?.rawValue ?? "")) ,
                "Rate": rate as NSNumber,
                "RSS": NSString(string: (rss?.absoluteString ?? "")),
                "Port": port as NSNumber,
                "Jingles": useJingles as NSNumber]
    }
}
