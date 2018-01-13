//
//  Speaker.swift
//  speaker
//
//  Created by UX Team Prague on 07.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import Cocoa

//Class for using synthetizer
class Speaker: NSObject, NSSpeechSynthesizerDelegate, MyXMLParserDelegate {
    
    private var speech: NSSpeechSynthesizer!
    var rss: URL?
    private var settings : Settings!
    private let xmlParser = MyXMLParser()
    private var readingRss = false
    private var startJingleSound : NSSound!
    private var endJingleSound : NSSound!
    
    init(settings: Settings) {
        super.init()
        
        self.settings = settings
        rss = settings.rss
        
        xmlParser.delegate = self
        
        //Start jingle
        let pathStartJingle = FileManager.default.currentDirectoryPath.appendingPathComponent("Resources/jingle.mp3")
        startJingleSound = NSSound(contentsOfFile: pathStartJingle, byReference: true)
        
        //end jingle
        let pathEndJingle = FileManager.default.currentDirectoryPath.appendingPathComponent("Resources/jingleend.mp3")
        endJingleSound = NSSound(contentsOfFile: pathEndJingle, byReference: true)
        
        //configure synthetizer with stored or default settings
        configureSpeechSynthesiser()
    }
    
    //configure synthetizer with stored or default settings
    private func configureSpeechSynthesiser() {
        speech = NSSpeechSynthesizer(voice: settings.voice)
        speech.delegate = self
        speech.volume = settings.volume
        speech.rate = settings.rate
    }
    
    //Set synthetizer's voice
    func setVoice(name: String) -> Bool{
        let id = "com.apple.speech.synthesis.voice." + name
        let result = speech.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: id))
        
        if (!result) {
            //new voice could not be set, try voice from settings
            setDefaultVoice()
        }
        return result
    }
    
    //Set voice with parameters from settings
    func setDefaultVoice() {
        speech.setVoice(settings.voice)
        speech.volume = settings.volume
        speech.rate = settings.rate
    }
    
    //set synthetizer's volume
    func setVolume(volume: Float){
        speech.volume = volume
    }
    
    //set synthetizer's rate
    func setRate(rate: Float) {
        speech.rate = rate
    }
    
    //set current synthetizer's configuration into Settings object and store it into plist
    func setCurrentConfigIntoSettings() -> Bool {
        settings.volume = speech.volume
        settings.voice = speech.voice()
        settings.rate = speech.rate
        settings.rss = rss
        
        //store settings into Settings.plist
        return settings.saveSettings()
    }
    
    //synthetize message
    func speak(message: String){
        //depending on settings, play jingle
        if (settings.useJingles) {
            playStartJingle()
        }
        
        speech.startSpeaking(message)
    }
    
    func sayError(error: String, message: String) {
        NSLog("%@", error)
        speak(message: message)
    }
    
    //start parsing xml from rss feed
    func readRss() -> Bool{
        if (settings.rss != nil) {
            xmlParser.startParsingWithContentsOfURL(rssURL: settings.rss!)
            return true
            
        } else {
            //no rss address is set
            return false
        }
    }
    
    //Play starting jingle
    private func playStartJingle() {
        startJingleSound.play()
        
        //let the whole jingle play
        Thread.sleep(forTimeInterval: startJingleSound.duration)
    }
    
    //play ending jingle
    private func playEndingJingle() {
        endJingleSound.play()
    }
    
    //synthetizer finished speaking
    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        
        //if reading rss or jingles are set in settings, play ending jingle
        if finishedSpeaking && (readingRss || settings.useJingles) {
            readingRss = false
            
            //short delay between end of the message and jingle
            Thread.sleep(forTimeInterval: 0.4)
            playEndingJingle()
        }
    }
    
    //Parsing of rss xml finished
    func parsingWasFinished() {
        
        //Choose random article
        let randomArticleIndex = Int(arc4random_uniform(UInt32(7)) + UInt32(2));
        if let articleTitle = xmlParser.arrParsedData[randomArticleIndex]["title"] {
            
            //read the article
            readingRss = true
            playStartJingle()
            speak(message: articleTitle)
        } else {
            //unable to read the article
            sayError(error: "RSS feed format or its address is not valid.",
                     message: "Obsah RSS fídu nebo jeho adresa není validní")
        }
    }
    
    //Parsing of xml finished with error
    func parsingFinishedWithError() {
        sayError(error: "RSS feed format or its address is not valid.",
                 message: "Obsah RSS fídu nebo jeho adresa není validní")
    }
}
