//
//  VisitedButtonView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/08.
//

import SwiftUI

struct VisitedButtonView: View {
    @EnvironmentObject var userData: UserData
    var documentID: String
    
    var body: some View {
        if !userData.visiteds.contains(documentID){
            Button(action: {
                userData.doVisited(document: documentID)
            }){
                VStack{
                    Image(systemName: "figure.walk.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                }
                .frame(width: 75, height: 75)
                .foregroundColor(Color("DarkBrown"))
                .background(Color.white)
                .cornerRadius(2)
                .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                        radius: 3, x: 2, y: 2)
            }
        } else {
            Button(action: {
                userData.undoVisited(document: documentID)
            }){
                VStack{
                    Image(systemName: "figure.walk.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                }
                .frame(width: 75, height: 75)
                .foregroundColor(Color("DarkBrown"))
            }
        }
    }
}
