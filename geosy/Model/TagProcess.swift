//
//  TagProcess.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/17.
//

import Foundation

public func tagProcess(rawTag: String) -> [String]{
    let separatedTag = rawTag.components(separatedBy: CharacterSet(charactersIn: "#＃"))
    let cleanedTag = separatedTag
        .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        .filter{$0 != ""}
    return cleanedTag
}
