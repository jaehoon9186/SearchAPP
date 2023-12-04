//
//  ParseXML.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

class SuggestionXMLParser: NSObject, XMLParserDelegate {
    private var suggestion: Suggestion?
    private var currentElement = ""
    private var words: [String] = []

    func xmlDecode(data: Data) throws -> Suggestion {

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        guard let suggestion = suggestion else {
            throw APIError.parsingError
        }
        return suggestion
    }

    // MARK: - XMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "suggestion" {
            words.append(attributeDict["data"]!)
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        suggestion = Suggestion(suggestedWords: words)
    }
}


