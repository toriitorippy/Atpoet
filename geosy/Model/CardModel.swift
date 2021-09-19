//
//  CardModel.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/09/04.
//

import Foundation
import SwiftUI

struct Card: Identifiable {
    let id: UUID = UUID()
    var iconImage: UIImage
    let title: String
    let star: Int
    let description: [String]
    var author: String
    let authorID: String
    let tag: [String]
    let hasImage: Bool
    let documentID: String
    let latitude: Double
    let longitude: Double
    let isHorizontal: Bool
}
