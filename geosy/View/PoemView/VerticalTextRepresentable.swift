//
//  VerticalTextRepresentable.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/31.
//

import Foundation
public struct VerticalTextRepresentable: UIViewRepresentable {
    public var text: String?

    public func makeUIView(context: Context) -> VerticalTextView {
        let uiView = VerticalTextView()
        uiView.isOpaque = false
        uiView.text = text
        return uiView
    }

    public func updateUIView(_ uiView: VerticalTextView, context: Context) {
        uiView.text = text
    }
}
