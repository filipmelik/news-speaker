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
    
    var shouldWait = true
    
    func startFun() {
        if let url = URL(string: "http://servis.idnes.cz/rss.aspx?c=zpravodaj") {
            speech = NSSpeechSynthesizer(voice: "com.apple.speech.synthesis.voice.zuzana.premium")
            speech.delegate = self
            
            let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            self.scriptDir = URL(fileURLWithPath: CommandLine.arguments[0], relativeTo: currentDirectoryURL).deletingLastPathComponent()
            
            xmlParser.delegate = self
            xmlParser.startParsingWithContentsOfURL(rssURL: url)
        }
    }
    
    // MARK: MyXMLParserDelegate
    
    
    func parsingWasFinished() {
        let randomArticleIndex = Int(arc4random_uniform(UInt32(7)) + UInt32(2));
        if let articleTitle = xmlParser.arrParsedData[randomArticleIndex]["title"] {
            
            NSSound(contentsOfFile: "\(scriptDir.path)/jingle.mp3", byReference: true)?.play()
            Thread.sleep(forTimeInterval: 3)
            
            speech.startSpeaking(articleTitle)
            
            var loopUntil = Date(timeIntervalSinceNow: 0.1)
            while (shouldWait && RunLoop.current.run(mode: .defaultRunLoopMode, before: loopUntil)) {
                loopUntil = Date(timeIntervalSinceNow: 0.1)
            }
        }
    }
    
    
    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        if finishedSpeaking {
            Thread.sleep(forTimeInterval: 0.4)
            NSSound(contentsOfFile: "\(scriptDir.path)/jingleend.mp3", byReference: true)?.play()
            Thread.sleep(forTimeInterval: 5)
            shouldWait = false
        }
    }
    
    
}

let speaker = Speaker()
speaker.startFun()
