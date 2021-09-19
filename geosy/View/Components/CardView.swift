//
//  CardView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/09/04.
//

import SwiftUI

struct CardView: View {
    @State var image: UIImage?
    let input: Card
    
    var body: some View {
        HStack{
            if input.hasImage {
                Image(uiImage: input.iconImage)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .clipped()
            }
            Spacer()
            VStack(alignment: .leading) {
                Spacer()
                if !input.title.isEmpty {
                    HStack{
                        Text(input.title)
                            .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Spacer()
                    }
                }
                if input.description.count > 0{
                    HStack{
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(input.description[0..<(min(2, input.description.count))], id: \.self) { data in
                                Text(data)
                                    .foregroundColor(.black)
                                    .fontWeight(.light)
                                    .lineLimit(nil)
                                    .lineSpacing(2)
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(.leading, 5.0)
        }
        .frame(minWidth: 250, maxHeight: 90)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        List{
        CardView(input: Card(iconImage: UIImage(named:"logo")!, title: "タイトル", star: 10, description: ["テストテストテストテストテストテスト", "テストテスト", "テストテストテストテストテストテスト","テスト", "テストテストテストテストテストテストテスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: false, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
        CardView(input: Card(iconImage: UIImage(named:"logo")!, title: "", star: 10, description: ["テスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
            CardView(input: Card(iconImage: UIImage(named:"logo")!, title: "", star: 10, description: ["テストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテスト", "テスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
            CardView(input: Card(iconImage: UIImage(named:"logo")!, title: "", star: 10, description: ["テストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
        }
    }
}
