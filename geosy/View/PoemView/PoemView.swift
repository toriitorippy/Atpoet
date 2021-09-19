//
//  PoemView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/15.
//

import SwiftUI

struct PoemView: View {
    var body: some View {
        NavigationView{
        HomeStackedCardView()
            .navigationBarHidden(true)
        }
    }
}

struct PoemView_Previews: PreviewProvider {
    static var previews: some View {
        PoemView()
    }
}
