//
//  Utils.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/08.
//

import Foundation

public func descriptionProcess(rawDescription: String) -> [String]{
    var lines = [String]()
    rawDescription.enumerateLines { (line, stop) -> () in
        lines.append(line)
    }
    return lines
}

public func tagProcess(rawTag: String) -> [String]{
    let separatedTag = rawTag.components(separatedBy: CharacterSet(charactersIn: "#＃"))
    let cleanedTag = separatedTag
        .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        .filter{$0 != ""}
    return cleanedTag
}
