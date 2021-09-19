//
//  MypageView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/13.
//

import CoreLocation

import SwiftUI

struct MypageView: View {
//    @StateObject var userData = UserData()
    @EnvironmentObject var userData: UserData
    @StateObject var poemViewModel = PoemViewModel()
    @State var alert = false
    @State var tag = ""
    @State private var showFollow = false
    @State private var showFriend = false
    @State private var showEdit = false
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                UserInfoView(showFollow: $showFollow, showFriend: $showFriend)
                
                VStack{
                    Image(uiImage: userData.database_user.image!)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    Button(action: {
                        showEdit = true
                    } ) {
                        Text("編集")
                            .font(.custom("Times-Roman", size: 12))
                            .foregroundColor(.black)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("DarkBrown"), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            PostView(userID: userData.database_user.id)
            NavigationLink(destination: FollowerView(user: userData.database_user, showFriend: $showFriend, showFollow: $showFollow)
                            .navigationBarHidden(true)
                           , isActive: $showFriend) {
                EmptyView()
            }
        }
        .sheet(isPresented: $showEdit) {
            EditView()
                .environmentObject(userData)
        }
        .navigationBarHidden(true)
    }
}


struct MypageView_Previews: PreviewProvider {
    static var previews: some View {
        MypageView()
    }
}
