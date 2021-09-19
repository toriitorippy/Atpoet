//
//  ValidPostedMapview.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/23.
//

//
//  ValidPostedMapView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/09.
//

import CoreLocation

import SwiftUI
import KeyboardObserving

struct ValidPostedMapView: View {
    @Binding var latitude : Double
    @Binding var longitude : Double
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
                    latitude = 0
                    longitude = 0
                }){
                    Text("削除")
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


struct ValidPostedMapView_Previews: PreviewProvider {
    static var previews: some View {
        ValidPostedMapView(latitude: .constant(0), longitude: .constant(0))
    }
}
