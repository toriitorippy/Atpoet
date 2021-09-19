//
//  UserUserCardView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/12.
//

import SwiftUI

struct UserCardView: View {
    let input: User
    
    var body: some View {
        HStack{
            Image(uiImage: input.image!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .clipped()
            Spacer()
            VStack(alignment: .leading) {
                Spacer()
                    HStack{
                        Text(input.name)
                            .foregroundColor(.black)//明示的に色を指定しないとbuttonでくるんだときにおかしくなる
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack{
                        Text(input.bodytext)
                                    .foregroundColor(.black)
                                    .fontWeight(.light)
                                    .lineLimit(2)
                                    .lineSpacing(2)
                        Spacer()
                    }
                Spacer()
            }
            .padding(.leading, 5.0)
        }
        .frame(minWidth: 250, maxHeight: 90)
    }
}

struct UserCardView_Previews: PreviewProvider {
    static var previews: some View {
        UserCardView(input: User())
    }
}
