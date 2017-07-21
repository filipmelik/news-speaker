//
//  main.swift
//  speaker
//
//  Created by Filip Melik on 14/07/2017.
//  Copyright © 2017 Filip Melik. All rights reserved.
//

import Foundation
import AppKit

class Speaker: NSObject, MyXMLParserDelegate, NSSpeechSynthesizerDelegate {
    
    let xmlParser = MyXMLParser()
    var task: Process!
    var speech: NSSpeechSynthesizer!
    var scriptDir: URL!
    
    // RunLoop wait flag
    var shouldWait = true
    
    
    override init() {
        super.init()
        
        configureSpeechSynthesiser()
        self.scriptDir = retrieveScriptDirectory()
    }
    
    
    func startFun() {
        if CommandLine.arguments.count == 2 {
            let messageToRead = CommandLine.arguments[1] // first argument is the message to read
            readMessage(messageToRead)
        } else {
            if let url = URL(string: "http://servis.idnes.cz/rss.aspx?c=zpravodaj") {
                xmlParser.delegate = self
                xmlParser.startParsingWithContentsOfURL(rssURL: url)
            }
        }
    }
    
    
    //
    // MARK: MyXMLParserDelegate
    //
    
    
    func parsingWasFinished() {
        let randomArticleIndex = Int(arc4random_uniform(UInt32(7)) + UInt32(2));
        if let articleTitle = xmlParser.arrParsedData[randomArticleIndex]["title"] {
            readMessage(articleTitle)
        }
    }
    
    
    //
    // MARK: NSSpeechSynthesizerDelegate
    //
    
    
    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        if finishedSpeaking {
            Thread.sleep(forTimeInterval: 0.4)
            playEndingJingle()
            
            // This is needed to break the RunLoop that waits until speaking is finished.
            shouldWait = false
        }
    }
    
    
    //
    // MARK: Helpers
    //
    
    
    private func configureSpeechSynthesiser() {
        speech = NSSpeechSynthesizer(voice: "com.apple.speech.synthesis.voice.zuzana.premium")
        speech.delegate = self
        speech.volume = 1
        speech.rate = 195
    }
    
    
    private func retrieveScriptDirectory() -> URL {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return URL(fileURLWithPath: CommandLine.arguments[0], relativeTo: currentDirectoryURL).deletingLastPathComponent()
    }
    
    
    private func waitUntilSpeakingIsFinished() {
        var loopUntil = Date(timeIntervalSinceNow: 0.1)
        while (shouldWait && RunLoop.current.run(mode: .defaultRunLoopMode, before: loopUntil)) {
            loopUntil = Date(timeIntervalSinceNow: 0.1)
        }
    }
    
    
    private func readMessage(_ message: String) {
        playStartJingle()
        speech.startSpeaking(message)
        waitUntilSpeakingIsFinished()
        // ending jingle is played in NSSpeechSynthesizerDelegate method
    }
    
    
    private func playStartJingle() {
        NSSound(contentsOfFile: "\(scriptDir.path)/resources/jingle.mp3", byReference: true)?.play()
        Thread.sleep(forTimeInterval: 3)
    }
    
    
    private func playEndingJingle() {
        NSSound(contentsOfFile: "\(scriptDir.path)/resources/jingleend.mp3", byReference: true)?.play()
        Thread.sleep(forTimeInterval: 5)
    }
    
    
}

let speaker = Speaker()
speaker.startFun()
