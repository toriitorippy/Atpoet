//
//  DestinationFullCardView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/13.
//

import SwiftUI

struct DestinationFullCardView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var canVisit = false
    let input: Card
    @State var backable = false
    
    var body: some View {
        ZStack{
            GeometryReader { (proxy: GeometryProxy) in
                FullCardView(canVisit: canVisit, input: input)
                    .navigationBarHidden(true)
                    .gesture(DragGesture()
                                .onChanged({ _ in
                                    backable = true
                                })
                                .onEnded({ value in
                                    if value.translation.width > proxy.size.width / 4 {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                    backable = true
                                })
                    )
                    .onTapGesture {
                        backable.toggle()
                    }
            }
            
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("DarkBrown"))
                            .background(Color(.white))
                            .clipShape(Circle())
                    }
                    .opacity(backable ? 1.0: 0.0)
                    .animation(.default)
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

