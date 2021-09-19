//
//  DraftListView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/24.
//

import SwiftUI

struct DraftListView: View{
    @Binding var draftDataList: [DraftDataItem]
    @Binding var presentedDraftData: DraftDataItem
    private let draftDataStore = DraftDataStore()
    @Environment(\.presentationMode) private var presentationMode
    @State var editMode: EditMode = .inactive
    var body: some View {
        NavigationView{
            List{
                ForEach(draftDataList) { draftData in
                    DraftView(draftData: draftData)
                        .onTapGesture {
                            presentedDraftData = draftData
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
                .onDelete(perform: rowRemove)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){ Button(action: { self.editMode = self.editMode.isEditing ? .inactive : .active }, label: {
                    if self.editMode.isEditing {
                        Text("完了")
                            .font(.custom("Times-Roman", size: 14))
                    } else {
                        Text("編集")
                            .font(.custom("Times-Roman", size: 14))
                    }
                })
                }
            }
            .environment(\.editMode, self.$editMode)
        }
        .accentColor(Color("DarkBrown"))
    }
    func rowRemove(offsets: IndexSet) {
        let index: Int = offsets.first!
        do {
            try draftDataStore.delete(id: draftDataList[index].objectID!)
        } catch let error {
            print(error.localizedDescription)
        }
        draftDataList.remove(atOffsets: offsets)
        if draftDataList.count == 0{
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DraftListView_Previews: PreviewProvider {
    static var previews: some View {
        DraftListView(draftDataList: .constant([
                                                DraftDataItem(
                                                    title: "Test",
                                                    body_text: "Testをすることはとても大事だと思います。なぜならば人間の認知機能には限界があり、Testなしでは正確な判断ができないからです。",
                                                    image: UIImage(systemName: "star")!,
                                                    latitude: 0,
                                                    longitude: 0,
                                                    tag: "#大事なこと#忘れるな", placeName: "", objectID: nil),
                                                DraftDataItem(
                                                    title: "preview",
                                                    body_text: "SwiftUIのpreview好き",
                                                    image: nil,
                                                    latitude: 0,
                                                    longitude: 0,
                                                    tag: "", placeName: "柏ハウス", objectID: nil)]),
                      presentedDraftData: .constant(
                        DraftDataItem(title: "preview", body_text: "SwiftUIのpreview好き", image: UIImage(systemName: "star")!, latitude: 0, longitude: 0, tag: "", placeName: "", objectID: nil)
                      )
        )
    }
}
