//
//  ServerHandler.swift
//  speaker
//
//  Created by Tomas Cerny on 09.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import Cocoa

//String extension for easy replacing of substring
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

//Class encapulsating the server
class ServerHandler: NSObject {
    
    private var speaker : Speaker!
    private let server = Server()
    
    init(speaker: Speaker) {
        super.init()
        
        self.speaker = speaker
      
        //Set server requests handlers
        setHelpFunction()
        setSayFunction()
        setSayPostFunction()
        setReadRssFunction()
        setStoreFunction()
        setRestartFunction()
        setVoicesFunction()
    }
    
    //Set handler for '/help' - show help message
    private func setHelpFunction() {
        server.get("/help") { _ in
            let help = """
                GET requests:
                   /say/{text}               - Read given text. Words are separated by \"-\".
                   /read-rss                 - Read random article title from set RSS feed.
                   /set                      - Change configuration of the speaker.
                                                Usage example: /set?voice=jorge, /set?volume=0.8&rate=170
                        ?voice={voice-name}  - Speaker voice (see /voices for all available options)
                        ?rate={rate}         - The synthesizer's speaking rate (words per minute) expressed in floating-point unit.
                                                Average human speech occurs at a rate of 180 to 220 words per minute.
                        ?volume={volume}     - The synthesizer's speaking volume is expressed in floating-point unit ranging from 0.0 through 1.0.
                   /voices                   - Show all available voices
                   /restart                  - Shutdown and restart the daemon
                   /help                     - Show this page

                POST requests:
                   /say                      - Read given text in POST body, using the content-type application/x-www-form-urlencoded.
                                                Usage example: curl -d "This is test."  http://localhost:8080/say
               """
            return .ok(help)
        }
    }
    
    //Set handler for '/say' function
    private func setSayFunction() {
        server.get("/say/{text}") { request in
            var result = ""
            
            let text = request.routeParams["text"]! as String
            
            //replace '-' with ' ' in text
            let textSeparated = text.replace(target: "-", withString:" ")
            
            result += "Saying: " + textSeparated
            
            //synthetize the message
            self.speaker.speak(message: textSeparated)
            
            return .ok(result)
        }
    }
    
    //Set handler for '/say' POST function
    private func setSayPostFunction() {
        server.post("/say") { request in
            var result = ""
            
            let text = String.init(bytes: request.body, encoding: String.Encoding.utf8)
            if let text = text {
                self.speaker.speak(message: text)
                result += "Saying: " + text
            } else {
                result += "Unable to find valid text in POST body. Use content-type application/x-www-form-urlencoded"
            }
            
            return .ok(result)
        }
    }
    
    //set handler for '/read-rss' function - read random article from rss feed
    private func setReadRssFunction() {
        server.get("/read-rss") { _ in
            var result = ""
            
            if (!self.speaker.readRss()) {
                
                //unable to read rss
                self.speaker.sayError(error: "RSS feed address is nots set.",
                                      message: "Není nastavena adresa RSS fídu")
                result = "Address of RSS feed is not set. Use /set or modify Settings.plist \n"
                
            } else {
                result = "Reading random article from RSS feed: " + self.speaker.rss!.absoluteString + "\n"
            }
            
            return .ok(result)
        }
    }
    
    //set handler for '/set' function - set various settings
    private func setStoreFunction() {
        server.get("/set") { request in
            var result = ""
            
            //check voice parameter
            if let voice = request.queryParams["voice"]{
                if (!self.speaker.setVoice(name: voice)) {
                    result = "Voice could not be changed. Check \"/voices\" to see all available voices.\n"
                } else {
                    result = "Setting voice: " + voice + "\n"
                }
            }
            
            //check volume parameter
            if let volumeString = request.queryParams["volume"] {
                if let volume = Float(volumeString) {
                    self.speaker.setVolume(volume: volume)
                    result += "Setting volume: " + volumeString + "\n"
                } else {
                    result += "Volume could not be changed, use float value in range 0.0 - 1.0.\n"
                }
            }
            
            //check rate parameter
            if let rateString = request.queryParams["rate"] {
                if let rate = Float(rateString) {
                    self.speaker.setRate(rate: rate)
                    result += "Setting rate: " + rateString + "\n"
                } else {
                    result += "Rate could not be changed, use float value. Average human speech occurs at a rate of 180 to 220 words per minute.\n"
                }
            }
            
            //check rss parameter
            if let rssString = request.queryParams["rss"] {
                if let rss = URL(string: rssString) {
                    self.speaker.rss = rss
                    result += "Setting RSS: " + rssString + "\n"
                } else {
                    result += "RSS could not be changed, use valid URL.\n"
                }
            }
            
            return .ok(result)
        }
    }
    
    //handler for '/restart' function - finish the service. If LaunchAgent is set to KeepAlive, will start again
    private func setRestartFunction() {
        server.get("/restart") { _ in
            running = false
            return .ok("Restarting server.\n")
        }
    }
    
    //handler for '/voices' funtion, prints all available voices
    private func setVoicesFunction() {
        server.get("/voices") { _ in
            let voiceIdentifiers = NSSpeechSynthesizer.availableVoices
            var voices = ""
            for voice in voiceIdentifiers {
                voices += voice.rawValue.components(separatedBy: ".").dropFirst(5).joined(separator: ".") + "\n"
            }
            return .ok(voices)
        }
    }
    
    //start the server on given port
    func runServer(port: Port) {
        server.run(port: port)
    }
    
    //check if the server is running
    func isRunning() -> Bool {
        return server.isRunning()
    }
}
