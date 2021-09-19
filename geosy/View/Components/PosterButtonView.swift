//
//  PosterButtonView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/12.
//

import SwiftUI

struct PosterButtonView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var viewModel = UserData()
    var input: Card
    @Binding var showPage: Bool
    @Binding var user: User
    
    var body: some View {
        Button(action: {
            showPage = true
        }){
            VStack{
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(input.author)
                    .foregroundColor(.black)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(width: 75, height: 75)
            .foregroundColor(Color("DarkBrown"))
            .background(Color.white)
            .cornerRadius(2)
            .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                    radius: 3, x: 2, y: 2)
        }
    }
}
