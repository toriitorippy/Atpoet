//
//  PostedImageView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/31.
//

import SwiftUI
import Firebase
import FirebaseStorageUI
import FirebaseStorage
import SDWebImage

public struct PostedImage: UIViewRepresentable {
    var url: String

    public func makeUIView(context: Context) -> UIImageView {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child(url)

        // UIImageView in your ViewController
        let imageView: UIImageView = UIImageView()

        // Placeholder image
        let placeholderImage = UIImage(named: "logo")

        // Load the image using SDWebImage
        imageView.sd_setImage(with: reference, placeholderImage: placeholderImage){ (image, error, cacheType, storageRef) in
            if let error = error {
                print("Error loading image: \(error)")
            }
        }
        return imageView
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {
    }
}
