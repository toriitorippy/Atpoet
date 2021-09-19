//
//  geosyApp.swift
//  geosy
//
//  Created by 宮下知也 on 2021/06/29.
//

import SwiftUI

@main
struct geosyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                    .environmentObject(UserData())
            }
        }
    }
}
