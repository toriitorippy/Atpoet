//
//  LoginContentView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/24.
//


import SwiftUI

struct LoginContentView: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        if userData.isFirst == false {
            LoginView()
        } else {
            // 初回登録時
            RegisterView()
        }
        
    }
}

struct login_ContentView_Previews: PreviewProvider {
    static let userData = UserData()
    static var previews: some View {
        LoginContentView().environmentObject(userData)
    }
}
