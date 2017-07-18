//
//  XmlParser.swift
//  speaker
//
//  Created by Filip Melik on 14/07/2017.
//  Copyright © 2017 Filip Melik. All rights reserved.
//

import Foundation



class MyXMLParser: NSObject, XMLParserDelegate {
    
    
    
    var arrParsedData = [Dictionary<String, String>]()
    
    var currentDataDictionary = Dictionary<String, String>()
    
    var currentElement = ""
    
    var foundCharacters = ""
    
    var delegate : MyXMLParserDelegate?
    
    func startParsingWithContentsOfURL(rssURL: URL) {
        if let parser = XMLParser(contentsOf: rssURL) {
            parser.delegate = self
            parser.parse()
        }
        
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:])
    {
        
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !foundCharacters.isEmpty {
            
            currentDataDictionary[currentElement] = foundCharacters
            
            foundCharacters = ""
            
            if currentElement == "pubDate" {
                arrParsedData.append(currentDataDictionary)
            }
        }
    }
    

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
    
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print(validationError)
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (currentElement == "title" || currentElement == "pubDate") {
            foundCharacters += string
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.parsingWasFinished()
    }
    
}

protocol MyXMLParserDelegate{
    func parsingWasFinished()
}
