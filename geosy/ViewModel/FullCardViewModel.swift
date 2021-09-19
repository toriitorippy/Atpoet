//
//  FullCardViewModel.swift
//  geosy
//
//  Created by 宮下知也 on 2021/09/01.
//

import Foundation

class FullCardViewModel: ObservableObject {
    public func calcHeight(text: [String]) -> Double {
        let textLength = text.map {
            $0.count
        }
        let maxLength = textLength.max() ?? 0
        return Double(maxLength * 40)
    }
}
