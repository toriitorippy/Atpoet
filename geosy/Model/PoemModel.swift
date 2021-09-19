//
//  PoemModel.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/11.
//

import Foundation

struct Poem: Identifiable {
  var id: String = UUID().uuidString
  var title: String
  var author: String
  var text: [String]
  var tag: Array<String>
  var star: Int
  var time: Date
}
