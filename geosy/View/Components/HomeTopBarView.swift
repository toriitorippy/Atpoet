//
//  HomeTopBarView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/10.
//
// ホーム画面の上側（フォロー中など）をデザイン

import SwiftUI

struct HomeTopBarView: View {
    var body: some View {
        HStack{
            Button(action: {} ) {
                HStack {
                    Text("新着")
                    Image(systemName: "chevron.down")
                }
                        .font(.custom("Times-Roman", size: 10))
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color("LightBrown"))
                }.frame(width: 70, height:50, alignment: .trailing)
            Spacer()
            Button(action: {} ) {
                    Text("すべて")
                        .font(.custom("Times-Roman", size: 10))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color("LightBrown"))
                        .cornerRadius(20)
                }.frame(width: 50, height:50, alignment: .trailing)
            Button(action: {} ) {
                    Text("フォロー中")
                        .font(.custom("Times-Roman", size: 10))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(20)
                }.frame(width: 70, height:50, alignment: .trailing)
        }
    }
}

struct HomeTopBarView_previews: PreviewProvider {
    static var previews: some View {
        HomeTopBarView()
    }
}
