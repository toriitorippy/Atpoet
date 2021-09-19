//
//  searchView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/11.
//

import SwiftUI

struct SearchView: View{
    @StateObject var poemViewModel = PoemViewModel()
    @Binding var tag: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        NavigationView{
            VStack(spacing: 0){
                ZStack{
                    HStack{
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("戻る")
                                .foregroundColor(Color(UIColor(named: "DarkBrown")!))
                        })
                        .padding([.top, .bottom], 10)
                        .padding(.leading, 15)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text("#" + tag)
                            .font(.title3)
                            .frame(maxWidth: 200)
                            .lineLimit(2)
                        Spacer()
                    }
                }
                Divider()
                    .background(Color(UIColor(named: "DarkBrown")!))
                List{
                    ForEach(Array(poemViewModel.tagCardViewInputs.enumerated()), id: \.offset) { i, input in
                        NavigationLink(destination: StackedCardView(cardViewInputs: poemViewModel.tagCardViewInputs, index: i)) {
                            CardView(input: input)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear(){
            self.poemViewModel.fetchTagData(tag: self.tag)
        }
        
    }
}
