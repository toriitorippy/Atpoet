//
//  ExampleViewController.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/07/28.
//

import Foundation
import FirebaseFirestore

// viewmodel
class ExampleViewModel: ObservableObject {
  @Published var books = [Book]()
  
  private var db = Firestore.firestore()
  
  func fetchData() {
    // データの取得
    let ref = db.collection("books")

    // ページ数降順で取得(おそらくdb.collection("books").order(by: "pages").limit(to: 3)でok)
    let orderdref = ref
        .whereField("pages", isGreaterThan: 100) // 100より大きいものに制限
        .whereField("pages", isLessThan: 1000)  // 1000より小さいものに制限
        .order(by: "pages", descending: true).limit(to: 5) // 並び替え降順
    
    orderdref.addSnapshotListener { (querySnapshot, error) in
      guard let documents = querySnapshot?.documents else {
        print("No documents")
        return
      }

      self.books = documents.map { queryDocumentSnapshot -> Book in
        let data = queryDocumentSnapshot.data()
        let title = data["title"] as? String ?? ""
        let author = data["author"] as? String ?? ""
        let numberOfPages = data["pages"] as? Int ?? 0

        return Book(title: title, author: author, numberOfPages: numberOfPages)
      }
    }
  }

    func addExampleData(title: String, author:String, pages:Int) {
        var ref: DocumentReference?
        // データの追加
        ref = db.collection("books").addDocument(data: [
            "title": title,
            "author": author,
            "pages": pages
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
  }
}
