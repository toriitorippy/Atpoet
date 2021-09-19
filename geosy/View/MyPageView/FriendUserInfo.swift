//
//  UserInfoView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//
import CoreLocation

import SwiftUI

struct FriendUserInfoView: View {
    @Binding var user: User
    @Binding var showFollow: Bool
    @Binding var showFriend: Bool
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text(user.name)
                    .font(.custom("Times-Roman", size: 24))
                    .padding(.leading)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.top, 10)
            HStack{
                Button(action: {
                    self.showFriend = true
                    self.showFollow = true
                } ) {
                    Text(String(user.follow.count) + "フォロー ")
                        .font(.custom("Times-Roman", size: 12))
                        .padding(.leading)
                        .foregroundColor(.black)
                }
                Button(action: {
                    self.showFriend = true
                    self.showFollow = false
                } ) {
                    Text(String(user.follower.count) + "フォロワー ")
                        .font(.custom("Times-Roman", size: 12))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            HStack{
                Text(user.bodytext)
                    .font(.custom("Times-Roman", size: 14))
                    .padding(.leading)
                Spacer()
            }
            .padding(.top, 5)
            .padding(.bottom, 10)
        }
    }
}
