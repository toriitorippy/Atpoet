//
//  FullCardView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/12.
//

import SwiftUI

struct FullCardView: View {
    
    @State var image: UIImage?
    @State private var bookmark = false
    @State private var showPoemMap = false
    
    let input: CardView.Input
    
    init(input: CardView.Input) {
        self.input = input
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack{
                    if !input.title.isEmpty{
                        Spacer()
                        HStack{
                            Text(input.title)
                                .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                                .font(.title)
                            Spacer()
                            //                            HStack(spacing: 4) {
                            //                                Image(systemName: "star")
                            //                                    .renderingMode(.template)
                            //                                    .foregroundColor(.gray)
                            //                                Text(String(input.star))
                            //                                    .font(.footnote)
                            //                                    .foregroundColor(.gray)
                            //                            }
                        }
                        .padding(.leading, 25.0)
                        .padding(.trailing, 10.0)
                        .padding(.top, 10.0)
                    }
                    if let image = image {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 170)
                            .clipped()
                            .cornerRadius(30)
                    }
                    if input.title.isEmpty && image == nil{
                        Spacer()
                    }
                    HStack(alignment: .top){
                        if true {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(input.description, id: \.self) { data in
                                    Text(data)
                                        .foregroundColor(.black)
                                        .font(.system(.body, design: .serif))
                                        .lineLimit(nil)
                                        .lineSpacing(5)
                                }
                            }
                            .padding(.top, 10.0)
                            .padding([.trailing, .leading], 25.0)
                            Spacer()
                        } else {
                            Spacer()
                            ForEach(input.description.reversed(), id: \.self) { data in
                                VerticalText(text: data, size: 20)
                                    .frame(width: 40, height: CGFloat(data.count)*20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.black)
                            }
                            .padding(10)
                            Spacer()
                        }
                    }
                    Spacer()
                    if !input.tag.isEmpty{
                        HStack{
                            Text(input.tag)
                                .foregroundColor(.black)
                                .lineLimit(nil)
                            Spacer()
                        }
                        .padding(.leading, 25.0)
                        .padding([.top], 20.0)
                    }
                    HStack {
                        Spacer()
                        Button(action: {}){
                            VStack{
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(input.author)
                                    .foregroundColor(.black)
                                    .font(.caption)
                            }
                            .frame(width: 75, height: 75)
                            .foregroundColor(Color("DarkBrown"))
                            .background(Color.white)
                            .cornerRadius(2)
                            .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                    radius: 3, x: 2, y: 2)
                        }
                        Spacer()
                        if !(input.latitude == 0.0 && input.longitude == 0){
                            Button(action: {
                                showPoemMap = true
                            }){
                                VStack{
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("場所")
                                        .foregroundColor(.black)
                                        .font(.caption)
                                    
                                }
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color("DarkBrown"))
                                .background(Color.white)
                                .cornerRadius(2)
                                .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                        radius: 3, x: 2, y: 2)
                            }
                            
                        }
                        Spacer()
                        if !bookmark{
                            Button(action: {
                                bookmark = true
                            }){
                                VStack{
                                    Image(systemName: "star")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    
                                }
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color("DarkBrown"))
                                .background(Color.white)
                                .cornerRadius(2)
                                .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                        radius: 3, x: 2, y: 2)
                            }
                        }else{
                            Button(action: {
                                bookmark = false
                            }){
                                VStack{
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    
                                }
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color("DarkBrown"))
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 30.0)
                    .padding(.top, 10.0)
                }
                
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
                //                　画像のみ別処理で呼び出し
                .onAppear {
                    if self.image == nil && input.hasImage{
                        self.image = UIImage(named: "logo")
                        let url = "atpoet_example/\(input.documentID).jpeg"
                        downloadImageAsync(url: url) { image in
                            self.image = image
                        }
                    }
                }
            }
            
        }
        .sheet(isPresented: $showPoemMap) {
            PoemMapView(latitude: input.latitude, longitude: input.longitude)
        }
    }
}

struct FullCardView_Previews: PreviewProvider {
    static var previews: some View {
        FullCardView(input: CardView.Input(iconImage: UIImage(named:"logo")!, title: "タイトル", star: 10, description: ["テストテストテストテストテストテスト", "テストテスト", "テストテストテストテストテストテスト","テスト", "テストテストテストテストテストテストテスト"], author:"てすと", tag:"#タグ", hasImage: true, documentID: "", latitude: 10, longitude: 10))
    }
}

