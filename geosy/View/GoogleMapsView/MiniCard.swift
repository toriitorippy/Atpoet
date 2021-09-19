//
//  MiniCard.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/07.
//

import SwiftUI

struct MiniCardView: View {
    @State var image: UIImage?
    @State private var showPoemMap = false
    
    let input: Card
    
    var body: some View {
        ZStack{
            Color(.white)
            VStack{
                Spacer()
                if !input.title.isEmpty{
                    HStack{
                        Text(input.title)
                            .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                            .fontWeight(.regular)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.leading, 5.0)
                    .padding(.trailing, 5.0)
                    .padding(.top, 5.0)
                }
                if input.hasImage && input.description.count == 0{
                    Image(uiImage: input.iconImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 70)
                        .clipped()
                        .cornerRadius(15)
                }
                if input.description.count > 0{
                    HStack(alignment: .top){
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(input.description[0..<(min(2, input.description.count))], id: \.self) { data in
                                Text(data)
                                    .foregroundColor(.black)
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                    .lineSpacing(5)
                            }
                        }
                        .padding(.top, 5.0)
                        .padding([.trailing, .leading], 5.0)
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(5)
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .padding(15)
                }
            }
        }
        .frame(minWidth: 200, idealWidth: 200, maxWidth: 200, minHeight: 120, idealHeight: 120, maxHeight: 120)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor(named: "DarkBrown")!), lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showPoemMap) {
            PoemMapView(latitude: input.latitude, longitude: input.longitude)
        }
    }
}

struct MiniCardView_Previews: PreviewProvider {
    static var previews: some View {
        MiniCardView(input: Card(iconImage: UIImage(named:"logo")!, title: "タイトル", star: 10, description: ["テストテストテストテストテストテスト", "テストテスト", "テストテストテストテストテストテスト","テスト", "テストテストテストテストテストテストテスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
            .previewLayout(.fixed(width: 200, height: 120))
    }
}
