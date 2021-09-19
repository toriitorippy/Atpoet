//
//  HomeStackedCardView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/15.
//

import SwiftUI

struct HomeStackedCardView: View {
    @State private var translation: CGSize = .zero
    @StateObject var viewModel = PoemViewModel()
    @State private var index: Int = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(viewModel.cardViewInputs) { cardViewInputs in
                        FullCardView(input: cardViewInputs)
                            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text("読込中...")
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .content.offset(x: self.offset) // 2. self.offsetとscrollViewのoffsetをバインディング
            .frame(width: proxy.size.width, height: nil, alignment: .leading)
            .gesture(DragGesture()
                        .onChanged({ value in  // 3. Dragを監視。Dragに合わせて、スクロールする。
                            self.offset = value.translation.width - proxy.size.width * CGFloat(self.index)
                        })
                        .onEnded({ value in // 4. Dragが完了したら、Drag量に応じて、indexを更新
                            let scrollThreshold = proxy.size.width / 2
                            if value.predictedEndTranslation.width < -scrollThreshold {
                                if (self.index + 3 > viewModel.cardViewInputs.count) {
                                    viewModel.fetchRandomData(max_poems: self.index + 3)
                                }
                                self.index = min(self.index + 1, viewModel.cardViewInputs.count - 1)
                            } else if value.predictedEndTranslation.width > scrollThreshold {
                                self.index = max(self.index - 1, 0)
                            }
                            withAnimation { // 5. 更新したindexの画像をアニメーションしながら表示する。
                                self.offset = -proxy.size.width * CGFloat(self.index)
                            }
                        })
            )
            .onAppear() {
                self.viewModel.fetchRandomData(max_poems: 3)
            }
        }
    }
}

struct HomeStackedCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStackedCardView()
    }
}
