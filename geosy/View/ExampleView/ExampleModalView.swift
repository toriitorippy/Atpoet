//
//  ExampleModalView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/07/28.
//

import SwiftUI

struct ExampleModalView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel = ExampleViewModel()
    @State private var title:String = ""
    @State private var author:String = ""
    @State private var pages:Int = 0
    
    var body: some View {
        
        VStack {
            Text("本のタイトル")
            TextField("タイトル", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())  // 入力域のまわりを枠で囲む
                .padding()  // 余白を追加
            Text("本の著者")
            TextField("著者", text: $author)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("本のページ数")
            TextField("ページ数", value: $pages, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.addExampleData(title: title, author: author, pages: pages)
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text("送信")
            })
            .padding()
            
            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text("閉じる")
            })
            
        }
    }
}

struct ExampleModalView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleModalView()
    }
}
