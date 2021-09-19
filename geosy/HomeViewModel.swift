//
//  HomeViewModel.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/11.
//

import Foundation
import Combine
import UIKit
import SwiftUI

final class HomeViewModel: ObservableObject {

    // MARK: - Inputs
    enum Inputs {
        case onCommit(text: String)
        case tappedCardView(urlString: String)
    }

    // MARK: - Outputs
    @Published private(set) var cardViewInputs: [Card] = []
    @Published var inputText: String = ""
    @Published var isShowError = false
    @Published var isLoading = false
    @Published var isShowSheet = false
    @Published var repositoryUrl: String = ""

}
