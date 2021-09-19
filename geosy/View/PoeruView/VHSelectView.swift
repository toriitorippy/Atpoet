//
//  VHSelectView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/10.
//

import SwiftUI

struct VHSelectView: View {
    @Binding var isHorizontal: Bool
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        isHorizontal = true
                    }, label: {
                        Text("横書き")
                            .foregroundColor(isHorizontal ? .primary: Color(UIColor.placeholderText))
                            .frame(width: geometry.size.width / 2)
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        isHorizontal = false
                    }, label: {
                        Text("縦書き")
                            .foregroundColor(isHorizontal ? Color(UIColor.placeholderText): .primary)
                            .frame(width: geometry.size.width / 2)
                    })
                    .buttonStyle(BorderlessButtonStyle())
                }
                Spacer()
            }
        }
    }
}
