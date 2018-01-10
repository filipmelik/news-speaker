# About

This LaunchAgent uses native macOS speech synthetiser to either read random news article title from RSS feed or just reads a text supplied using HTTP GET request.

# Installation
You need to have Xcode IDE installed on your mac.
Just type `sudo make install`. Installation directory is `Applications/Speaker`.  Installation Makefile uses sudo. After the installation, agent is automatically loaded.
For uninstallation, just type `sudo make uninstall`. Root privileges for `make` are needed to write `plist` into `/Library/LaunchAgents` (deploy agent).

# Using the speaker
You can communicate with the app using HTTP API. Default address is `http://localhost:8080/`.
#### Description of the API:
```
/say/{text}           - Read given text. Words are separated by "-".
/read-rss             - Read random article title from set RSS feed.
/set                  - Change and store configuration of the speaker.
Usage example: /set?voice=jorge, /set?volume=0.8&rate=170
?voice={voice-name} - Speaker voice (see /voices for all available options)
?rate={rate}        - The synthesizer's speaking rate (words per minute) expressed in floating-point unit.
Average human speech occurs at a rate of 180 to 220 words per minute.
?volume={volume}    - The synthesizer's speaking volume is expressed in floating-point unit ranging from 0.0 through 1.0.
/voices               - Show all available voices
/restart              - Shutdown and restart the daemon
/help                 - Show this page
```

#### Settings
Application uses settings stored in `/Applications/Speaker/Settings.plist`. Valid keys and values are:
```
RSS     [String]  - URL adress of the RSS feed
Rate    [Number]  - The synthesizer's speaking rate (words per minute) expressed in floating-point unit.
Volume  [Number]  - The synthesizer's speaking volume is expressed in floating-point unit ranging from 0.0 through 1.0.
Voice   [String]  - Full name of the sysnthetizer's voice
Jingles [Boolean] - If true, jingles are used also for /say
Port    [Number]  - Port for the server
```
If no `Settings.plist` is provided, default values are used.

# Notes
In case of any error, user is informed either by HTML content or directly by synthetizer.

# Used libraries
#### BiAtoms/Http.swift
A tiny HTTP server engine written in swift. See [Http.swift](https://github.com/BiAtoms/Http.swift)
