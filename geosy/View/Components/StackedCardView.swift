//
//  StackedCardView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/15.
//

import SwiftUI

struct StackedCardView: View {
    @State private var translation: CGSize = .zero
    var cardViewInputs: [Card]
    @State var index: Int = 0
    @State private var offset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var backable = false
    
    var body: some View {
        ZStack{
            GeometryReader { (proxy: GeometryProxy) in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(cardViewInputs) { cardViewInput in
                            FullCardView(input: cardViewInput)
                                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                        }
                    }
                }
                .content.offset(x: self.offset) // 2. self.offsetとscrollViewのoffsetをバインディング
                .frame(width: proxy.size.width, height: nil, alignment: .leading)
                .gesture(DragGesture()
                            .onChanged({ value in  // 3. Dragを監視。Dragに合わせて、スクロールする。
                                self.offset = value.translation.width - proxy.size.width * CGFloat(self.index)
                                backable = true
                            })
                            .onEnded({ value in // 4. Dragが完了したら、Drag量に応じて、indexを更新
                                let scrollThreshold = proxy.size.width / 2
                                if value.predictedEndTranslation.width < -scrollThreshold {
                                    self.index = min(self.index + 1, cardViewInputs.count - 1)
                                } else if value.predictedEndTranslation.width > scrollThreshold {
                                    self.index = max(self.index - 1, 0)
                                }
                                withAnimation { // 5. 更新したindexの画像をアニメーションしながら表示する。
                                    self.offset = -proxy.size.width * CGFloat(self.index)
                                }
                            })
                )
                .onAppear(){
                    self.offset = -proxy.size.width * CGFloat(self.index)
                }
            }
            .onTapGesture {
                backable.toggle()
            }
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("DarkBrown"))
                            .background(Color(.white))
                            .clipShape(Circle())
                    }
                    .opacity(backable ? 1.0: 0.0)
                    .animation(.default)
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct StackedCardView_Previews: PreviewProvider {
    static var previews: some View {
        StackedCardView(cardViewInputs: [Card(iconImage: UIImage(named:"logo")!, title: "タイトル", star: 10, description: ["テストテストテストテストテストテスト", "テストテスト", "テストテストテストテストテストテスト","テスト", "テストテストテストテストテストテストテスト"], author:"てすと", authorID: "authorID", tag:["#タグ"], hasImage: true, documentID: "", latitude: 10, longitude: 10, isHorizontal: true)])
    }
}

