//
//  VertivalTextView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/31.
//

import UIKit
import CoreText
import SwiftUI


public struct VerticalText: UIViewRepresentable {
    public var text: String?
    public var size: Double?
    
    public func makeUIView(context: Context) -> VerticalTextView {
        let uiView = VerticalTextView()
        uiView.text = text
        uiView.size = size
        uiView.isOpaque = false
        return uiView
    }
    
    public func updateUIView(_ uiView: VerticalTextView, context: Context) {
        uiView.text = text
    }
}

public class VerticalTextView: UIView {
    public var size: Double?
    public var text: String? = nil {
        didSet {
            ctFrame = nil
        }
    }
    private var ctFrame: CTFrame? = nil
    
    override public func draw(_ rect: CGRect) {
        
        guard let context:CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.height)
        
        let baseAttributes: [NSAttributedString.Key : Any] = [
            .verticalGlyphForm: true,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(size ?? 13.0)),
        ]
        let attributedText = NSMutableAttributedString(string: text ?? "", attributes: baseAttributes)
        let setter = CTFramesetterCreateWithAttributedString(attributedText)
        let path = CGPath(rect: rect, transform: nil)
        let frameAttrs = [
            kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue,
        ]
        let ct = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, frameAttrs as CFDictionary)
        ctFrame = ct
        CTFrameDraw(ct, context)
    }
}

struct VerticalText_Previews: PreviewProvider {
    static var previews: some View {
        VerticalText(text: """
縦書きのテスト
Tategakiのテスト
Ver10……
""", size: 18).padding(40)
    }
}
