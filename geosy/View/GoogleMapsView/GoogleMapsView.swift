//
//  GoogleMapsView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/06.
//

import SwiftUI
import UIKit
import MapKit
import GoogleMaps
import GoogleMapsUtils
import FirebaseFirestore
import FirebaseStorage
import GeoFire

struct GoogleMapsView: View {
    @EnvironmentObject var userData: UserData
    @State var map_manager = CLLocationManager()
    @State var alert = false
    @State var showFullCard = false
    @State var cardList = [Card]()
    @State var cardID = 0
    @State var canVisit = false
    @State var zoomLevel: Float = 17
    var fetchZoom: Float = 11.0
    
    var body: some View {
        ZStack{
            // このifとTextがないとBindingしてる値が何故か更新されなくてerrorが出るので入れている。
            // おそらく更新を通知するかどうかがView内にあるかに依存するから（sheet内にあっても更新が通知されない）
            // クソ仕様と言わざるを得ない
            if cardList.count > 0{
                Text(String(cardID))
            }
            GoogleMapsRepresentable(manager: $map_manager, alert: $alert, cardList: $cardList, cardID: $cardID, showFullCard: $showFullCard, zoomLevel: $zoomLevel, canVisit: $canVisit)
                .alert(isPresented: $alert) {
                    Alert(title: Text("現在位置に近い投稿の表示や、投稿に位置情報を用いるためには、設定機能から位置情報へのアクセスを許可してください"))
                }
            if zoomLevel < fetchZoom{
                VStack{
                    Text("投稿を取得するにはズームしてください")
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(30)
                        .padding()
                    Spacer()
                }
            }
            if cardList.count > 0 {
                NavigationLink(destination: DestinationFullCardView(canVisit: canVisit, input: cardList[cardID])
                                .navigationBarHidden(true)
                               , isActive: $showFullCard) {
                    EmptyView()
                }
            }
        }
    }
}
