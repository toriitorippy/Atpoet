//
//  FullCardView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/12.
//

import SwiftUI

struct FullCardView: View {
    @EnvironmentObject var userData: UserData
    @State var image: UIImage?
    @State private var showPoemMap = false
    var canVisit = false
    @State private var showSearch = false
    @State private var showPage = false
    @State var selectedTag = ""
    @State var selectedUser = User(name: "")

    let input: Card

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack{
                    if !input.title.isEmpty{
                        HStack{
                            Text(input.title)
                                .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                                .font(.title)
                            Spacer()
                        }
                        .padding([.trailing, .leading], 25.0)
                        .padding(.top, 30.0)
                    }
                    if let image = image {
                        if input.description.count == 0 {
                            Spacer()
                        }
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 170)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.top, input.description.count == 0 ? 0: 30)
                    }
                    if input.description.count > 0 {
                        Spacer()
                        HStack(alignment: .top){
                            if input.isHorizontal {
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
                                    VerticalText(text: data, size: 18)
                                        .frame(width: 55, height: CGFloat(data.count)*18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                        }
                        .padding(.top, 30)
                    }
                    Spacer()
                    if input.tag.count > 0{
                        VStack{
                            ForEach(input.tag, id: \.self) { data in
                                HStack{
                                Button(action: {
                                    selectedTag = data
                                    showSearch = true
                                },
                                label: {
                                    Text("#" + data)
                                        .foregroundColor(.blue)
                                        .lineLimit(nil)
                                        Spacer()
                                })
                                .buttonStyle(BorderlessButtonStyle())
                                    }
                            }
                        }
                        .padding([.trailing, .leading], 25.0)
                        .padding([.top], 20.0)
                    }
                    HStack {
                        Spacer()
                        PosterButtonView(input: input, showPage: $showPage, user: $selectedUser)
                        Spacer()
                        if canVisit {
                            VisitedButtonView(documentID: input.documentID)
                        } else if !(input.latitude == 0.0 && input.longitude == 0){
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
                        BookMarkButtonView(documentID: input.documentID)
                        Spacer()
                    }
                    .padding(.bottom, 30.0)
                    .padding(.top, 10.0)
                    NavigationLink(destination:
                                    DestinationFriendpageView(user: selectedUser, authorID: input.authorID),
                                   isActive: $showPage) {
                        EmptyView()
                    }
                    NavigationLink(destination: SearchView(tag: $selectedTag)
                                    .navigationBarHidden(true)
                                   , isActive: $showSearch) {
                        EmptyView()
                    }
                }

                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
                //                　画像のみ別処理で呼び出し
                .onAppear {
                    if self.image == nil && input.hasImage{
                        self.image = UIImage(named: "logo")
                        let url = "poem/\(input.documentID).jpeg"
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
        FullCardView(input: Card(iconImage: UIImage(named:"logo")!, title: "タイトル", star: 10, description: ["テストテストテストテストテストテスト", "テストテスト", "テストテストテストテストテストテスト","テスト", "テストテストテストテストテストテストテスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true))
    }
}
