//
//  ContentView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/06/29.
//

import SwiftUI
import CoreLocation

struct ContentView: View {

    @EnvironmentObject var userData: UserData

    init() {
        // 背景色を指定
        UITabBar.appearance().barTintColor = UIColor(named: "LightBrown")
        // 選択していないアイテム色を指定
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "DarkBrown")
    }

    var body: some View {
        if !userData.isSignedIn || !userData.isfetched {
            LoginContentView()
                .onAppear() {
                    userData.fetchMyUserData()
                }
        } else {
            TabView {
                PoemView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                NavigationView{
                    GoogleMapsView()
                        .navigationBarHidden(true)
                }
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map") }
                PoeruView()
                    .tabItem {
                        Image(systemName: "highlighter")
                        Text("投稿") }
//                MasterPoeruView()
//                    .tabItem {
//                        Image(systemName: "list.dash")
//                        Text("管理者") }
                NavigationView{
                    MypageView()
                }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("マイページ") }

                // dbの仕様を確認する用の画面
//                ExampleView()
//                    .tabItem {
//                        Image(systemName: "tray")
//                        Text("example")
//                    }
            }
            .accentColor(.white) // 選択したアイテム色を指定
            .onAppear() {
                userData.fetchMyUserData()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
