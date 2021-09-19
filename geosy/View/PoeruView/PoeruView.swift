//
//  PoeruView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/09.
//

import CoreLocation

import SwiftUI
import Combine
import KeyboardObserving

struct PoeruView: View {
    
    init() {
        // TextEditorのプレースホルダーを見えるようにするため
        // これやらないとダメなのはクソ仕様すぎるのでそのうち公式で修正が入ると思う
        UITextView.appearance().backgroundColor = .clear
        
        do {
            draftDataList = try draftDataStore.fetchAll()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    @State private var presentedDraft: DraftDataItem = DraftDataItem()
    @State private var showDraft = false
    @State private var showImagePicker = false
    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var showMap = false
    @State private var showValidPostedMap = false
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var image: UIImage?
    private let draftDataStore = DraftDataStore()
    @State private var draftDataList: [DraftDataItem] = []
    @StateObject var poemViewModel = PoemViewModel()
    @EnvironmentObject var userData: UserData
    @State private var updating = false
    
    
    private let maxTitle = 100
    private let maxBodyText = 5000
    private let maxTag = 200
    
    var body: some View {
        ZStack{
        NavigationView{
                List{
                    HStack{
                        Button(action: {
                            showImagePicker = true
                        }){
                            Image(uiImage: presentedDraft.image ?? UIImage(named:"logo")!)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        TextField("タイトル", text: $presentedDraft.title)
                            .accentColor(.blue)
                            .onReceive(Just(presentedDraft.title)) { _ in
                                if presentedDraft.title.count > maxTitle {
                                    presentedDraft.title = String(presentedDraft.title.prefix(maxTitle))
                                }
                            }
                    }
                    .padding(.top)
                    TextEditor(text: $presentedDraft.body_text)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                        .padding(.top)
                        .background(
                            (presentedDraft.body_text.isEmpty ? Text("本文") : Text(""))
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 24)
                                .padding(.leading, 5)
                            ,alignment: .topLeading
                        )
                        .accentColor(.blue)
                        .onReceive(Just(presentedDraft.body_text)) { _ in
                            if presentedDraft.body_text.count > maxBodyText {
                                presentedDraft.body_text = String(presentedDraft.body_text.prefix(maxBodyText))
                            }
                        }
                    
                    TextField("タグ(例: #俳句 #詩)", text: $presentedDraft.tag)
                        .accentColor(.blue)
                        .onReceive(Just(presentedDraft.tag)) { _ in
                            if presentedDraft.tag.count > maxTag {
                                presentedDraft.tag = String(presentedDraft.tag.prefix(maxTag))
                            }
                        }
                    VHSelectView(isHorizontal: $presentedDraft.isHorizontal)
                    if presentedDraft.latitude == 0{
                        Button(action: {showMap = true}, label:
                                {
                                    HStack{
                                        Text("位置情報")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .foregroundColor(.black)
                                    }
                                })
                            .buttonStyle(BorderlessButtonStyle())
                    } else {
                        Button(action: {showValidPostedMap = true}, label:
                                {
                                    PostedMapView(latitude: presentedDraft.latitude, longitude: presentedDraft.longitude, allowGesture: false)
                                        .frame(height: 300)
                                })
                            .buttonStyle(BorderlessButtonStyle())
                    }
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack {
                            Button(action: {
                                if presentedDraft.objectID != nil{
                                    do {
                                        try draftDataStore.delete(id: presentedDraft.objectID!)
                                    } catch let error {
                                        print(error.localizedDescription)
                                    }
                                }
                                do {
                                    try draftDataStore.insert(item: presentedDraft)
                                    presentedDraft = DraftDataItem()
                                } catch let error {
                                    print(error.localizedDescription)
                                }
                            } , label: {
                                Text("保存")
                                    .font(.custom("Times-Roman", size: 12))
                                    .foregroundColor(Color(red: 166/255, green: 139/255, blue: 98/255))
                                    .padding(8)
                            })
                            // なぜかSpacerがないと表示されない
                            Spacer()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing){
                        HStack {
                            Button(action: {
                                do {
                                    draftDataList = try draftDataStore.fetchAll()
                                } catch let error {
                                    print(error.localizedDescription)
                                }
                                self.showDraft.toggle()
                            } , label: {
                                Text("下書き")
                                    .font(.custom("Times-Roman", size: 12))
                                    .foregroundColor(Color(red: 166/255, green: 139/255, blue: 98/255))
                                    .padding(8)
                            })
                            Button(action: {
                                
                                if !presentedDraft.isPostable(){
                                    showAlert = true
                                    alertText = "タイトル・本文・画像のいずれかを入力してください"
                                } else if !presentedDraft.isHorizontal &&  !presentedDraft.isPostableVerticale(){
                                    showAlert = true
                                    alertText = "縦書きの場合は1行100文字以内・5行以内で入力してください"
                                } else {
                                    updating = true
                                    poemViewModel.addPoemData(draftDataItem: presentedDraft, author: "zunbako", author_id: userData.database_user.id){
                                        if presentedDraft.objectID != nil{
                                            do {
                                                try draftDataStore.delete(id: presentedDraft.objectID!)
                                            } catch let error {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        updating = false
                                        presentedDraft = DraftDataItem()
                                    }
                                }
                            } , label: {
                                Text("投稿")
                                    .font(.custom("Times-Roman", size: 12))
                                    .foregroundColor(Color.white)
                                    .padding(8)
                                    .background(Color(red: 166/255, green: 139/255, blue: 98/255))
                                    .cornerRadius(20)
                            })
                        }
                    }
                }
            }
            
            if updating{
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.6)
                ProgressView("")
            }
        }
        .keyboardObserving()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)}
        .sheet(isPresented: $showDraft) {
            DraftListView(draftDataList: $draftDataList, presentedDraftData: $presentedDraft)
        }
        .sheet(isPresented: $showValidPostedMap) {
            ValidPostedMapView(latitude: $presentedDraft.latitude, longitude: $presentedDraft.longitude)
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
            ImagePicker(sourceType: .photoLibrary, selectedImage: $presentedDraft.image, updateImage: .constant(false))
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $presentedDraft.image, updateImage: .constant(false))
        }
        .fullScreenCover(isPresented: $showMap) {
            PoeruPlaceView(presentedDraft: $presentedDraft)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(""),
                  message: Text(alertText),
                  dismissButton: .default(Text("確認")))
        }
    }
}


struct PoeruView_Previews: PreviewProvider {
    static var previews: some View {
        PoeruView()
    }
}
