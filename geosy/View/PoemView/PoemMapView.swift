//
//  PoemMapView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/01.
//

import CoreLocation

import SwiftUI
import KeyboardObserving

struct PoemMapView: View {
    var latitude : Double
    var longitude : Double
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Image(systemName: "chevron.backward")
                        .padding(15)
                        .foregroundColor(Color(red: 166/255, green: 139/255, blue: 98/255))
                }
                .padding(10)
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Text("戻る")
                        .font(.custom("Times-Roman", size: 16))
                        .padding(15)
                        .foregroundColor(Color(red: 166/255, green: 139/255, blue: 98/255))
                }
                .padding(10)
            }
            PostedMapView(latitude: latitude, longitude: longitude, allowGesture: true)
        }
    }
}


struct PoemMapView_Previews: PreviewProvider {
    static var previews: some View {
        PoemMapView(latitude: 0, longitude: 0)
    }
}
