//
//  FollowerView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//

import CoreLocation

import SwiftUI

struct FollowerView: View {
    var user: User
    @Binding var showFriend: Bool
    @Binding var showFollow: Bool
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                ZStack{
                    HStack{
                        Button(action: {
                            self.showFriend = false
                        } ) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(Color("DarkBrown"))
                        }
                        .padding()
                        Spacer()
                    }
                    Text(user.name)
                        .font(.custom("Times-Roman", size: 20))
                        .padding()
                }
                HStack{
                    VStack{
                        Button(action: {
                            self.showFollow = true
                        } ) {
                            HStack{
                                Spacer()
                                Text("フォロー")
                                    .font(.custom("Times-Roman", size: 14))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                        Rectangle()
                            .foregroundColor(Color("DarkBrown"))
                            .frame(height: self.showFollow ? 4: 0.8)
                            .cornerRadius(10)
                            .animation(.default)
                    }
                    
                    VStack{
                        Button(action: {
                            self.showFollow = false
                        } ) {
                            HStack{
                                Spacer()
                                Text("フォロワー")
                                    .font(.custom("Times-Roman", size: 14))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                        Rectangle()
                            .foregroundColor(Color("DarkBrown"))
                            .frame(height: self.showFollow ? 0.8: 4)
                            .cornerRadius(10)
                            .animation(.default)
                    }
                }
                List{
                    if self.showFollow{
                        ForEach(Array(user.follow.keys), id: \.self) { key in
                            NavigationLink(
                                destination: DestinationFriendpageView(user: user.follow[key]!, authorID: user.follow[key]!.id)
                            ){
                                UserCardView(input: user.follow[key]!)
                            }
                        }
                    } else{
                        ForEach(Array(user.follower.keys), id: \.self) { key in
                            NavigationLink(
                                destination: DestinationFriendpageView(user: user.follower[key]!, authorID: user.follower[key]!.id)
                            ){
                                UserCardView(input: user.follower[key]!)
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct FollowerView_Previews: PreviewProvider {
    static var previews: some View {
        FollowerView(user: User(), showFriend: .constant(false), showFollow: .constant(false))
    }
}
