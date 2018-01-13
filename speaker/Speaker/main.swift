//
//  main.swift
//  speaker
//
//  Created by Tomas Cerny on 05.01.18.
//  Copyright © 2018 Heureka. All rights reserved.
//

import Foundation

func parseCommandLineArguments () -> String? {
    if (CommandLine.arguments.count >= 2) {
        return CommandLine.arguments[1]
    }
    
    return nil
}

let settingsPath = parseCommandLineArguments()
//load settings from Settings.plist
let settings = Settings(plistPath: settingsPath)

//create speaker instance
let speaker = Speaker(settings: settings)

//while true, service is running
var running = true

//create object with server
let serverHandler = ServerHandler(speaker: speaker)

//run server
serverHandler.runServer(port: settings.port)


//while server is running and service is on - infinite loop
var loopUntil = Date(timeIntervalSinceNow: 0.1)
while (running && RunLoop.current.run(mode: .defaultRunLoopMode, before: loopUntil)) {
    
    //check if server is running
    if (!serverHandler.isRunning()) {
        speaker.sayError(error: "Unable to launch server, try to set anothet port",
                         message: "Server se nepodařilo spustit. Zkuste nastavit jiný port.")
        Thread.sleep(forTimeInterval: 5)
        
        //server is not running -> stop the service
        running = false
        
    } else {
        loopUntil = Date(timeIntervalSinceNow: 0.1)
    }
}

