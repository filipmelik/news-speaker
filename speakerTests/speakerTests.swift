//
//  speakerTests.swift
//  speakerTests
//
//  Created by UX Team Prague on 13.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import XCTest

class speakerTests: XCTestCase {
    
    func testLoadingSettingsFromValidFile() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "validSettings", withExtension: "plist")
        
        let settingsLoader = SettingsLoader(plistPath: fileURL?.path)
        let settings = settingsLoader.loadSettings()
        
        XCTAssertEqual(settings.port, 1234, "Port was not loaded correctly")
        XCTAssertEqual(settings.useJingles, true, "Use jingles was not loaded correctly")
        XCTAssertEqual(settings.voice, NSSpeechSynthesizer.VoiceName(rawValue: "com.apple.speech.synthesis.voice.yuri"), "Voice was not loaded correctly")
        XCTAssertEqual(settings.volume, 0.67, "Port was not loaded correctly")
        XCTAssertEqual(settings.rate, 188, "Rate was not loaded correctly")
        XCTAssertEqual(settings.rss, URL(string: "http://servis.idnes.cz/rss.aspx?c=zpravodaj"), "RSS was not loaded correctly")
    }
    
    func testLoadingSettingsFromInvalidFile() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "invalidSettings", withExtension: "plist")
        
        let settingsLoader = SettingsLoader(plistPath: fileURL?.path)
        let settings = settingsLoader.loadSettings()
        
        XCTAssertEqual(settings.port, Settings.DefaultValue.port, "Port was not loaded correctly")
        XCTAssertEqual(settings.useJingles, Settings.DefaultValue.useJingles, "Use jingles was not loaded correctly")
        XCTAssertEqual(settings.voice, Settings.DefaultValue.voice, "Voice was not loaded correctly")
        XCTAssertEqual(settings.volume, Settings.DefaultValue.volume, "Port was not loaded correctly")
        XCTAssertEqual(settings.rate, Settings.DefaultValue.rate, "Rate was not loaded correctly")
        XCTAssertEqual(settings.rss, URL(string: Settings.DefaultValue.rss), "RSS was not loaded correctly")
    }
    
    func testLoadingSettingsInvalidValues() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "invalidValues", withExtension: "plist")
        
        let settingsLoader = SettingsLoader(plistPath: fileURL?.path)
        let settings = settingsLoader.loadSettings()
        
        XCTAssertEqual(settings.port, Settings.DefaultValue.port, "Port was not loaded correctly")
        XCTAssertEqual(settings.useJingles, Settings.DefaultValue.useJingles, "Use jingles was not loaded correctly")
        XCTAssertEqual(settings.voice, Settings.DefaultValue.voice, "Voice was not loaded correctly")
        XCTAssertEqual(settings.volume, Settings.DefaultValue.volume, "Port was not loaded correctly")
        XCTAssertEqual(settings.rate, Settings.DefaultValue.rate, "Rate was not loaded correctly")
        XCTAssertEqual(settings.rss, URL(string: Settings.DefaultValue.rss), "RSS was not loaded correctly")
    }
    
    func testLoadingSettingFromNonExistingFile() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "nonExistingFile", withExtension: "plist")
        
        let settingsLoader = SettingsLoader(plistPath: fileURL?.path)
        let settings = settingsLoader.loadSettings()
        
        XCTAssertEqual(settings.port, Settings.DefaultValue.port, "Port was not loaded correctly")
        XCTAssertEqual(settings.useJingles, Settings.DefaultValue.useJingles, "Use jingles was not loaded correctly")
        XCTAssertEqual(settings.voice, Settings.DefaultValue.voice, "Voice was not loaded correctly")
        XCTAssertEqual(settings.volume, Settings.DefaultValue.volume, "Port was not loaded correctly")
        XCTAssertEqual(settings.rate, Settings.DefaultValue.rate, "Rate was not loaded correctly")
        XCTAssertEqual(settings.rss, URL(string: Settings.DefaultValue.rss), "RSS was not loaded correctly")
    }
    
}
