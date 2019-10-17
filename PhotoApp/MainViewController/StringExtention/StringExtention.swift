//
//  StringExtention.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/16/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import Foundation

extension String {
    func findMentionText() -> [String] {
        var arrHasStrings: [String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)) {
            for match in matches {
                let foundedString = NSString(string: self).substring(with: NSRange(location: match.range.location, length: match.range.length ))
                if foundedString != "#"{
                arrHasStrings.append(foundedString)
                }
            }
        }
        return arrHasStrings
    }
}
