INSTALL_DIR=~/news-speaker

clean:
	rm -rf ./build/

install: speaker.xcodeproj
	xcodebuild
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)/resources
	cp ./speaker/resources/jingle.mp3 $(INSTALL_DIR)/resources
	cp ./speaker/resources/jingleend.mp3 $(INSTALL_DIR)/resources
	cp ./build/Release/speaker $(INSTALL_DIR)/speaker
	chmod +x $(INSTALL_DIR)/speaker

uninstall: 
	rm -rf $(INSTALL_DIR)
