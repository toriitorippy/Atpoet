//
//  PostView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//
import CoreLocation

import SwiftUI

struct PostView: View {
    @State var showPost = true
    @State var showBookmark = false
    @StateObject var poemViewModel = PoemViewModel()
    var userID: String
    
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Button(action: {
                        self.showPost = true
                        self.showBookmark = false
                    } ) {
                        HStack{
                            Spacer()
                            Text("投稿")
                                .font(.custom("Times-Roman", size: 14))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    Rectangle()
                        .foregroundColor(Color("DarkBrown"))
                        .frame(height: showPost ? 4: 0.8)
                        .cornerRadius(10)
                        .animation(.default)
                }
                
                VStack{
                    Button(action: {
                        self.showPost = false
                        self.showBookmark = true
                    } ) {
                        HStack{
                            Spacer()
                            Text("ブックマーク")
                                .font(.custom("Times-Roman", size: 14))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    Rectangle()
                        .foregroundColor(Color("DarkBrown"))
                        .frame(height: (showPost || !showBookmark) ? 0.8: 4)
                        .cornerRadius(10)
                        .animation(.default)
                }
                VStack{
                    Button(action: {
                        self.showPost = false
                        self.showBookmark = false
                    } ) {
                        HStack{
                            Spacer()
                            Text("訪れた")
                                .font(.custom("Times-Roman", size: 14))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    Rectangle()
                        .foregroundColor(Color("DarkBrown"))
                        .frame(height: (showPost || showBookmark) ? 0.8: 4)
                        .cornerRadius(10)
                        .animation(.default)
                }
            }
            if self.showPost {
                List {
                    ForEach(Array(poemViewModel.myCardViewInputs.enumerated()), id: \.offset) { i, input in
                        NavigationLink(destination: StackedCardView(cardViewInputs: poemViewModel.myCardViewInputs, index: i)) {
                            CardView(input: input)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else if self.showBookmark {
                List {
                    ForEach(Array(poemViewModel.bookmarkCardViewInputs.enumerated()), id: \.offset) { i, input in
                        NavigationLink(destination: StackedCardView(cardViewInputs: poemViewModel.bookmarkCardViewInputs, index: i)) {
                            CardView(input: input)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                
                List {
                    ForEach(Array(poemViewModel.visitCardViewInputs.enumerated()), id: \.offset) { i, input in
                        NavigationLink(destination: StackedCardView(cardViewInputs: poemViewModel.visitCardViewInputs, index: i)) {
                            CardView(input: input)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear() {
            if poemViewModel.ismyLoading {
                self.poemViewModel.fetchMyData(author_id: userID)
            }
            if poemViewModel.isBookmarkLoading {
                self.poemViewModel.fetchBookmarkData(author_id: userID)
            }
            if poemViewModel.isVisitLoading {
                self.poemViewModel.fetchVisitData(author_id: userID)
            }
        }
    }
}


struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(userID: "6cUJrzh3owQNeNA28v4egRyaToq1")
    }
}
