clean:
	rm -rf ./build/

install: speaker.xcodeproj
	xcodebuild
	sudo cp speaker/com.heureka.speaker.agent.plist /Library/LaunchAgents
	launchctl load /Library/LaunchAgents/com.heureka.speaker.agent.plist

uninstall:
	launchctl unload /Library/LaunchAgents/com.heureka.speaker.agent.plist
	rm -rf /Applications/Speaker
	sudo rm -f /Library/LaunchAgents/com.heureka.speaker.agent.plist
