//
//  UserModel.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/31.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct User: Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var image: UIImage? = UIImage(named:"logo")
    var bodytext: String = ""
    var follow = [String: User]()
    var follower = [String: User]()
    var imageUrl: String = ""
    var documentID: String = ""
    var image_url: String = ""
    mutating func updateData(user: User) {
        self.id = user.id
        self.name = user.name
        self.bodytext = user.bodytext
        self.imageUrl = user.imageUrl
        self.documentID = user.documentID
        self.image_url = user.image_url
    }
}
