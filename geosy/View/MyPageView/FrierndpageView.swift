//
//  FrierndpageView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//

import CoreLocation

import SwiftUI

struct FriendpageView: View {
    @StateObject var poemViewModel = PoemViewModel()
    @StateObject var userViewModel = UserData()
    @EnvironmentObject var userData: UserData
    @State var alert = false
    @State var user: User
    @State var tag = ""
    @State private var showFollow = false
    @State private var showFriend = false
    let authorID: String
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                FriendUserInfoView(user: $user, showFollow: $showFollow, showFriend: $showFriend)
                VStack{
                    Image(uiImage: user.image!)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    if userData.follow.contains(user.id){
                        Button(action: {
                            userData.undoFollow(user_id: user.id)
                        } ) {
                            Text("フォローを外す")
                                .font(.custom("Times-Roman", size: 12))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color("DarkBrown"))
                                .cornerRadius(20)
                        }
                    } else {
                        Button(action: {
                            userData.doFollow(user_id: user.id)
                        } ) {
                            Text("フォローする")
                                .font(.custom("Times-Roman", size: 12))
                                .foregroundColor(.black)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("DarkBrown"), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            PostView(userID: authorID)
            NavigationLink(destination: FollowerView(user: user, showFriend: $showFriend, showFollow: $showFollow)
                            .navigationBarHidden(true)
                           , isActive: $showFriend) {
                EmptyView()
            }
        }
        .onAppear(){
            userViewModel.fetchUserData(uid: authorID) { User in
                self.user.updateData(user: User)
                downloadImageAsync(url: user.image_url) { image in
                    if let image = image{
                        user.image = image
                    }
                }
            }
            userViewModel.fetchFollowerData(uid: authorID){ follower in
                self.user.follower = follower
                for (k, _follower) in self.user.follower {
                    downloadImageAsync(url: _follower.imageUrl) { image in
                        if let image = image{
                            self.user.follower[k]?.image = image
                        }
                    }
                }
            }
            userViewModel.fetchFollowData(uid: authorID){ follow in
                self.user.follow = follow
                for (k, _follow) in self.user.follow {
                    downloadImageAsync(url: _follow.imageUrl) { image in
                        if let image = image{
                            self.user.follow[k]?.image = image
                        }
                    }
                }
            }
        }
    }
}

struct FriendpageView_Previews: PreviewProvider {
    static var previews: some View {
        FriendpageView(user: User(name: "テスト"), authorID: "")
    }
}
