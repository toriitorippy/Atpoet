//
//  PoeruPlaceView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/26.
//

import CoreLocation

import SwiftUI

struct PoeruPlaceView: View {
    @State var poeru_manager = CLLocationManager()
    @State var alert = false
    @State var hasPin : Bool = false
    @State var latitude : Double = 0
    @State var longitude : Double = 0
    @Binding var presentedDraft: DraftDataItem
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("キャンセル")
                })
                .padding(.top)
                .padding(.leading)
                Spacer()
            }
            ZStack{
                PoeruPlaceMapView(manager: $poeru_manager, alert: $alert, hasPin: $hasPin, latitude: $latitude, longitude: $longitude)
                    .alert(isPresented: $alert)
                    {
                        Alert(title: Text("現在位置に近い投稿の表示や、投稿に位置情報を用いるためには、設定機能から位置情報へのアクセスを許可してください"))
                    }
                VStack{
                    Spacer()
                    Button(action: {
                        if hasPin{
                            self.presentationMode.wrappedValue.dismiss()
                            presentedDraft.latitude = latitude
                            presentedDraft.longitude = longitude
                            presentedDraft.reverseGeocode(){placeName in
                                presentedDraft.placeName = placeName ?? ""
                            }
                        }
                    } ) {
                        HStack {
                            Text("決定")
                            Image(systemName: "chevron.down")
                        }
                        .font(.custom("Times-Roman", size: 16))
                        .padding(15)
                        .foregroundColor(Color.black)
                        .background(Color(red: 239/255, green: 232/255, blue: 218/255))
                    }
                    .opacity(hasPin ? 1.0: 0.4)
                    .padding(10)
                }
            }
        }
    }
}


struct PoeruPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PoeruPlaceView(presentedDraft: .constant(DraftDataItem(title: "Test", body_text: "Testをすることはとても大事だと思います。なぜならば人間の認知機能には限界があり、Testなしでは正確な判断ができないからです。", image: nil, latitude: 0, longitude: 0, tag: "#大事なこと#忘れるな", placeName: "@柏ハウス")))
    }
}
