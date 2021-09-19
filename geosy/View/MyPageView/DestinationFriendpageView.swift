//
//  DestinationFriendView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//

import SwiftUI

struct DestinationFriendpageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userData: UserData
    var user: User
    let authorID: String
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(Color("DarkBrown"))
                    }
                    .padding([.top, .leading], 20)
                    Spacer()
                }
                if userData.database_user.id == authorID{
                    MypageView()
                } else {
                    FriendpageView(user: user, authorID: authorID)
                }
            }
            .navigationBarHidden(true)
        }
        // FollowerViewからLinkされた時用
        .navigationBarHidden(true)
    }
}

