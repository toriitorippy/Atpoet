//
//  ExampleModel.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/07/28.
//

import Foundation

struct Book: Identifiable {
  var id: String = UUID().uuidString
  var title: String
  var author: String
  var numberOfPages: Int
}
