//
//  AppDelegate.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/06.
//

import Foundation
import GooglePlaces
import GoogleMaps
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSPlacesClient.provideAPIKey(APIKey)
        GMSServices.provideAPIKey(APIKey)
        FirebaseApp.configure()
        Auth.auth().signInAnonymously()
        return true
    }
 }
