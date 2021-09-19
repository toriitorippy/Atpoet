//
//  RegisterName.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/09/01.
//

import SwiftUI
import Foundation
import GoogleSignIn
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var userData: UserData
    @State var name = ""
    
    var body: some View {
        ZStack{
            Color(.white)
                .edgesIgnoringSafeArea(.all)
            if userData.register_status == 0 {
                NameRegisterView(name: $name)
            }
            if userData.register_status == 1 {
                ImageRegisterView(name: $name)
            }
        }
    }
}

struct NameRegisterView: View {
    @EnvironmentObject var userData: UserData
    @Binding var name: String
    @State private var showAlert = false
    @State private var alertText = ""
    
    var body: some View {
        ZStack {
            VStack{
                HStack {
                    Button(action: {
                        //　一旦ログアウト
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            userData.isSignedIn = false
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                        userData.isFirst = false
                    }){
                        VStack{
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                                .padding(20)
                            
                        }
                    }
                    Spacer()
                    
                }
                Spacer()
            }
            VStack{
                Text("あなたのお名前は？")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.gray)
                    .frame(width: 300, height: 50, alignment: .bottom)
                TextField("あなたのお名前", text: $name)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .frame(width: 300, height: 200, alignment: .center)
            }
            VStack{
                Spacer()
                Button(action: {
                    if (name == "") {
                        showAlert = true
                        alertText = "名前を入力してください"
                    } else {
                        userData.register_status = 1
                    }
                } ) {
                    Text("次へ")
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .frame(minWidth: 250)
                        .padding()
                        .background(Color(UIColor(named: "DarkBrown")!))
                        .cornerRadius(15)
                        .padding(20)
                }
                
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""),
                      message: Text(alertText),
                      dismissButton: .default(Text("確認")))
            }
        }
    }
}

struct ImageRegisterView: View {
    @EnvironmentObject var userData: UserData
    @State private var showImagePicker = false
    @State private var showLibrary = false
    @State private var showCamera = false
    @Binding var name: String
    @State private var updating = false
    
    var body: some View {
        ZStack() {
            VStack {
                HStack {
                    Button(action: {
                        userData.register_status = 0
                    }){
                        VStack{
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                                .padding(20)
                            
                        }
                    }
                    Spacer()
                    
                }
                Spacer()
            }
            
            VStack{
                Button(action: {
                    showImagePicker = true
                }){
                    Image(uiImage: userData.database_user.image!)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .clipped()
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Text("プロフィール画像の設定")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.gray)
                    .frame(width: 300, height: 50, alignment: .bottom)
                
            }
            VStack{
                Spacer()
                Button(action: {
                    updating = true
                    userData.addImageData(image: userData.database_user.image, fileName: userData.database_user.id){
                        userData.addUserName(name: name) {
                            userData.isFirst = false
                            userData.isSignedIn = true
                            userData.isfetched = true
                            updating = false
                        }
                    }
                } ) {
                    Text("登録")
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .frame(minWidth: 250)
                        .padding()
                        .background(Color(UIColor(named: "DarkBrown")!))
                        .cornerRadius(15)
                        .padding(20)
                }
                
            }
            if updating{
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.6)
                ProgressView("")
            }
        }
        .actionSheet(isPresented: $showImagePicker) {
            () -> ActionSheet in
            ActionSheet(
                title: Text(""),
                buttons: [
                    .default(
                        Text("ライブラリを開く"),
                        action:{showLibrary = true}
                    ),
                    .default(
                        Text("カメラを開く"),
                        action:{showCamera = true}
                    ),
                    .cancel(Text("キャンセル"))
                ]
            )
        }
        .fullScreenCover(isPresented: $showLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $userData.database_user.image, updateImage: .constant(false))
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $userData.database_user.image, updateImage: .constant(false))
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
