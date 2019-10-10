//
//  HashtagParser.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/1/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import Foundation
struct RegexParser {
    
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    
    
    static func getElements(from text: String ) -> [NSTextCheckingResult]{
        guard let elementRegex = regularHashtagExpression() else { return [] }
        let textlength = text.utf16.count
        let textRange = NSRange(location: 0, length: textlength)
        let a = elementRegex.matches(in: text, options: [], range: textRange)
        return a
    }
    
    private static func regularHashtagExpression() -> NSRegularExpression? {
        if let createdRegex = try? NSRegularExpression(pattern: hashtagPattern, options: [.caseInsensitive]) {
            return createdRegex
        } else {
            return nil
        }
    }
}
typealias ActiveFilterPredicate = ((String) -> Bool)
typealias ElementTuple = (range: NSRange, element: String)


struct ActiveBuilder {
    
    static func createElements(from text: String, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        
        let matches = RegexParser.getElements(from: text)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > 2 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }
            
            elements.append((match.range, word))
            
        }
        return elements
        
        
        
    }
    
}

