//
//  DraftView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/24.
//

import SwiftUI
import CoreLocation

struct DraftView: View{
    var draftData: DraftDataItem
    
    var body: some View {
        HStack{
            if draftData.image != nil{
                Image(uiImage: draftData.image!)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            VStack(alignment: .leading) {
                Text(draftData.title)
                    .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                    .font(.title)
                    .fontWeight(.bold)
                Text(draftData.body_text)
                    .foregroundColor(.black)
                    .lineLimit(nil)
                Text(draftData.placeName)
                    .foregroundColor(.black)
                    .lineLimit(nil)
                HStack{
                    Text(draftData.tag)
                        .foregroundColor(.black)
                        .lineLimit(nil)
                    Spacer()
                }
            }
        }
        .padding(5)
        //        横幅はちゃんと画面の横幅に合わせる必要がある
        .frame(minWidth: 250, maxHeight: 400)
    }
}

struct DraftView_Previews: PreviewProvider {
    static var previews: some View {
        DraftView(draftData: DraftDataItem(title: "Test", body_text: "Testをすることはとても大事だと思います。なぜならば人間の認知機能には限界があり、Testなしでは正確な判断ができないからです。", image: nil, latitude: 0, longitude: 0, tag: "#大事なこと#忘れるな", placeName: "@柏ハウス"))
    }
}
