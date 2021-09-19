//
//  EditView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/14.
//

import SwiftUI
import Combine

struct EditView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    @State private var initial = true
    @State private var updating = false
    @State private var updateImage = false
    @State private var local_userName = ""
    @State private var local_bodyText = ""
    @State private var local_image = UIImage(named:"logo")
    @State private var showImagePicker = false
    @State private var showLibrary = false
    @State private var showCamera = false
    init() {
        // TextEditorのプレースホルダーを見えるようにするため
        // これやらないとダメなのはクソ仕様すぎるのでそのうち公式で修正が入ると思う
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: {
                        userData.database_user.image = local_image
                        userData.database_user.name = local_userName
                        userData.database_user.bodytext = local_bodyText
                        self.presentationMode.wrappedValue.dismiss()
                    } ) {
                        Text("キャンセル")
                            .font(.custom("Times-Roman", size: 14))
                            .padding(12)
                            .foregroundColor(Color("DarkBrown"))
                    }
                    Spacer()
                    Button(action: {
                        updating = true
                        if updateImage {
                            userData.updateUserImage(image: userData.database_user.image, fileName: userData.database_user.id){
                                userData.updateUserInfo(id: userData.database_user.id, name: userData.database_user.name, body_text: userData.database_user.bodytext.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")){
                                        updating = false
                                        self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            userData.updateUserInfo(id: userData.database_user.id, name: userData.database_user.name, body_text: userData.database_user.bodytext.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")){
                                    updating = false
                                    self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } ) {
                        Text("保存")
                            .font(.custom("Times-Roman", size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("DarkBrown"))
                            .cornerRadius(20)
                            .padding(12)
                    }
                }
                List{
                    HStack{
                        Button(action: {
                            showImagePicker = true
                        }){
                            Image(uiImage: userData.database_user.image!)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        TextField("名前", text: $userData.database_user.name)
                    }
                    TextEditor(text: $userData.database_user.bodytext)
                        .padding(.top)
                        .background(
                            (userData.database_user.bodytext.isEmpty ? Text("自己紹介") : Text(""))
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 24)
                                .padding(.leading, 5)
                            ,alignment: .topLeading
                        )
                        .onReceive(Just(local_bodyText)) { _ in
                            if userData.database_user.bodytext.count > 70 {
                                userData.database_user.bodytext = String(userData.database_user.bodytext.prefix(70))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 120)
                    
                }
            }
            
            if updating{
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.6)
                ProgressView("")
            }
        }
        .onAppear() { //キャンセルした時に反映されないようにローカル変数として持つ
            if initial {
                print("initial!!!")
                local_userName = userData.database_user.name
                local_bodyText = userData.database_user.bodytext
                local_image = userData.database_user.image
                initial = false
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
            ImagePicker(sourceType: .photoLibrary, selectedImage: $userData.database_user.image, updateImage: $updateImage)
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $userData.database_user.image, updateImage: $updateImage)
        }
    }
}


//struct EditView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditView(userName: .constant("とりとり@影"),  bodyText: .constant(""), image: .constant(UIImage(named:"logo")!),user_id: .constant(""))
//    }
//}
