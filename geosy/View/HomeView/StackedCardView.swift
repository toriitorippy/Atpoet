//
//  StackedCardView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/15.
//

import SwiftUI

struct StackedCardView: View {
    @State private var translation: CGSize = .zero
    @ObservedObject var viewModel = PoemViewModel()
    @State private var index: Int = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            NavigationView{
                ZStack {
                    if viewModel.isLoading {
                        Text("読込中...")
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(0..<viewModel.num_poems) { (i: Int) in
                                    FullCardView(input: viewModel.cardViewInputs[i])
                                        .frame(width: proxy.size.width, height: proxy.size.height + 16 * 3, alignment: .center)
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
                                            if (self.index + 1 == viewModel.num_poems) {
                                                print("over")
                                                viewModel.isLoading = true
                                                viewModel.fetchNewData()
                                                self.index = self.index + 1
                                            } else {
                                            self.index = min(self.index + 1, viewModel.num_poems - 1)
                                            }
                                        } else if value.predictedEndTranslation.width > scrollThreshold {
                                            self.index = max(self.index - 1, 0)
                                        }
                                        
                                        withAnimation { // 5. 更新したindexの画像をアニメーションしながら表示する。
                                            self.offset = -proxy.size.width * CGFloat(self.index)
                                        }
                                    })
                        )
                    }
                }
                .onAppear() { // (3)
                    print("stacked featch")
                    self.viewModel.fetchData()
                }
            }
        }
    }
}

struct StackedCardView_Previews: PreviewProvider {
    static var previews: some View {
        StackedCardView()
    }
}
