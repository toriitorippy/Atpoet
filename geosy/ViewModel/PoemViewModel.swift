//
//  PoemViewModel.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/11.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import GeoFire


class PoemViewModel: ObservableObject {
    @Published var poem = [Poem]()
    @Published var cardViewInputs = [Card]()
    @Published var tagCardViewInputs = [Card]()
    @Published var myCardViewInputs = [Card]()
    @Published var bookmarkCardViewInputs = [Card]()
    @Published var visitCardViewInputs = [Card]()
    @Published var isShowError = false
    @Published var ismyLoading = true
    @Published var isBookmarkLoading = true
    @Published var isVisitLoading = true
    @Published var fetch_poems = 1 //一度に取得するポエム数
    private var viewedDocumentId = [String]()
    
    private var db = Firestore.firestore()
    
    func fetchRandomData(max_poems: Int) {
        let ref = db.collection("poem")
        let orderdref = ref
            .order(by: "order", descending: true).limit(to: 1) // 並び替え降順
        //                    .order(by: "time", descending: true).limit(to: self.fetch_poems) // 並び替え降順
        
        orderdref.getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in fetch order data")
                print("ERROR: \(error)")
                return
            }
            
            var newCardViewInputs = documents.map { queryDocumentSnapshot ->  Int in
                return queryDocumentSnapshot.data()!["order"] as? Int ?? 0
            }
            let maxOrder = newCardViewInputs[0]
            if maxOrder == 0 { return }
            let randomInt = Int.random(in: 1..<maxOrder)
            let orderdref = ref
                .whereField("order", isGreaterThanOrEqualTo: randomInt)
                .order(by: "order").limit(to: self.fetch_poems) // 並び替え降順
            
            orderdref.getDocuments() { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents in fetch random data")
                    print("ERROR: \(error)")
                    return
                }
                
                var newCardViewInputs = documents.map { queryDocumentSnapshot ->  Card in
                    let cardViewInput = self.convertSnapshot(snapshot: queryDocumentSnapshot)
                    return cardViewInput
                }
                
                newCardViewInputs = newCardViewInputs.filter({!self.viewedDocumentId.contains($0.documentID)})
                self.viewedDocumentId.append(contentsOf: newCardViewInputs.map({$0.documentID}))
                if self.cardViewInputs.count < max_poems - 1{
                    self.fetchRandomData(max_poems: max_poems)
                }
                for (i, input) in newCardViewInputs.enumerated() {
                    self.getAuthorName(input: input) { authorName in
                        newCardViewInputs[i].author = authorName
                        self.cardViewInputs.append(contentsOf: newCardViewInputs)
                    }
                }
            }
        }
    }
    
    func fetchTagData(tag: String) {
        let ref = db.collection("poem")
        let orderdref = ref
            .whereField("tag", arrayContains: tag)
            .order(by: "time", descending: true) // 並び替え降順
        
        orderdref.getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in tag data")
                print("ERROR: \(error)")
                return
            }
            
            self.tagCardViewInputs = documents.map { queryDocumentSnapshot ->  Card in
                let cardViewInput = self.convertSnapshot(snapshot: queryDocumentSnapshot)
                return cardViewInput
            }
            
            for (i, input) in self.tagCardViewInputs.enumerated() {
                self.getAuthorName(input: input) { authorName in
                    self.tagCardViewInputs[i].author = authorName
                }
            }
            
            for (i, input) in self.tagCardViewInputs.enumerated() {
                if input.hasImage {
                    let url = "poem/\(input.documentID).jpeg"
                    downloadImageAsync(url: url) { image in
                        self.tagCardViewInputs[i].iconImage = image!
                    }
                }
            }
        }
    }
    
    func getAuthorName(input: Card, completion: @escaping ((String) -> ())){
        let ref = db.collection("users").document(input.authorID)
        ref.addSnapshotListener { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("No documents")
                return
            }
            let name = document.data()?["name"] as? String ?? ""
            completion(name)
        }
    }
    
    func convertSnapshot(snapshot: QueryDocumentSnapshot) -> Card {
        let data = snapshot.data()
        let documentID = snapshot.documentID
        return convertDict(data: data, documentID: documentID)
    }
    
    func convertDocument(document: DocumentSnapshot) -> Card {
        let data = document.data()!
        let documentID = document.documentID
        return convertDict(data: data, documentID: documentID)
    }
    
    func convertDict(data: [String : Any], documentID: String)  -> Card {
        let title = data["title"] as? String ?? ""
        let star = data["star"] as? Int ?? 0
        let description = data["text"] as? String ?? ""
        let author = data["author"] as? String ?? ""
        let authorID = data["author_id"] as? String ?? ""
        let hasImage = data["image"] as? Bool ?? false
        let tag: [String] = data["tag"] as? [String] ?? []
        let place = data["place"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
        let latitude = place.latitude
        let longitude = place.longitude
        let isHorizontal = data["isHorizontal"] as? Bool ?? true
        let processedDescription = descriptionProcess(rawDescription: description)
        let iconImage = UIImage(named: "logo")!
        
        return Card(iconImage: iconImage, title: title, star: star, description: processedDescription, author:author, authorID: authorID, tag:tag, hasImage: hasImage, documentID: documentID, latitude: latitude, longitude: longitude, isHorizontal: isHorizontal)
    }
    
    func fetchMyData(author_id: String) {
        // データの取得
        let ref = db.collection("poem")
        var image:UIImage = UIImage(named: "top_logo")!
        
        let orderdref = ref
            .whereField("author_id", isEqualTo: author_id)
            .order(by: "time", descending: true) // 並び替え降順
        //    num_poems = orderdref.accessibilityElementCount()
        
        orderdref.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in my post data")
                print("ERROR: \(error)")
                return
            }
            
            self.myCardViewInputs = documents.map { queryDocumentSnapshot ->  Card in
                let cardViewInput = self.convertSnapshot(snapshot: queryDocumentSnapshot)
                return cardViewInput
                
            }
            
            self.ismyLoading = false
            
            for (i, input) in self.myCardViewInputs.enumerated() {
                self.getAuthorName(input: input) { authorName in
                    self.myCardViewInputs[i].author = authorName
                }
            }
            
            //            　それぞれのcardについて画像を同期
            for (i, input) in self.myCardViewInputs.enumerated() {
                if input.hasImage {
                    let url = "poem/\(input.documentID).jpeg"
                    downloadImageAsync(url: url) { image in
                        self.myCardViewInputs[i].iconImage = image!
                    }
                }
            }
        }
    }
    
    func fetchBookmarkData(author_id: String) {
        // データの取得
        let ref = db.collection("poem")
        
        let orderdref = ref
            .whereField("bookmark_id", arrayContains: author_id)
            .order(by: "time", descending: true) // 並び替え降順
        
        orderdref.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in bookmark data")
                print("ERROR: \(error)")
                return
            }
            
            
            self.bookmarkCardViewInputs = documents.map { queryDocumentSnapshot ->  Card in
                let cardViewInput = self.convertSnapshot(snapshot: queryDocumentSnapshot)
                return cardViewInput
            }
            
            self.isBookmarkLoading = false
            
            for (i, input) in self.bookmarkCardViewInputs.enumerated() {
                self.getAuthorName(input: input) { authorName in
                    self.bookmarkCardViewInputs[i].author = authorName
                }
            }
            
            //            　それぞれのcardについて画像を同期
            for (i, input) in self.bookmarkCardViewInputs.enumerated() {
                if input.hasImage {
                    let url = "poem/\(input.documentID).jpeg"
                    downloadImageAsync(url: url) { image in
                        self.bookmarkCardViewInputs[i].iconImage = image!
                    }
                }
            }
        }
    }
    
    func fetchVisitData(author_id: String) {
        // データの取得
        let ref = db.collection("poem")
        
        let orderdref = ref
            .whereField("visit_id", arrayContains: author_id)
            .order(by: "time", descending: true) // 並び替え降順
        
        orderdref.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in visit data")
                print("ERROR: \(error)")
                return
            }
            
            self.visitCardViewInputs = documents.map { queryDocumentSnapshot ->  Card in
                let cardViewInput = self.convertSnapshot(snapshot: queryDocumentSnapshot)
                return cardViewInput
            }
            
            self.isVisitLoading = false
            
            for (i, input) in self.visitCardViewInputs.enumerated() {
                self.getAuthorName(input: input) { authorName in
                    self.visitCardViewInputs[i].author = authorName
                }
            }
            
            //            　それぞれのcardについて画像を同期
            for (i, input) in self.visitCardViewInputs.enumerated() {
                if input.hasImage {
                    let url = "poem/\(input.documentID).jpeg"
                    downloadImageAsync(url: url) { image in
                        self.visitCardViewInputs[i].iconImage = image!
                    }
                }
            }
        }
    }
    
    func addPoemData(draftDataItem: DraftDataItem, author: String, author_id: String, completion: @escaping (() -> ())) {
        let ref = db.collection("poem").document()
        var addData = [
            "title": draftDataItem.title,
            "star": 0,
            "text": draftDataItem.body_text,
            "author": author,
            "tag": tagProcess(rawTag: draftDataItem.tag),
            "time": Date(),
            "author_id": author_id,
            "image": draftDataItem.image != nil,
            "isHorizontal": draftDataItem.isHorizontal,
            "order": 0
        ] as [String : Any]
        if !(draftDataItem.latitude == 0 && draftDataItem.longitude == 0){
            let place = GeoPoint(latitude: draftDataItem.latitude, longitude: draftDataItem.longitude)
            addData.updateValue(place, forKey: "place")
            let location = CLLocationCoordinate2D(latitude: draftDataItem.latitude, longitude: draftDataItem.longitude)
            let hash = GFUtils.geoHash(forLocation: location)
            addData.updateValue(hash, forKey: "geoHash")
        }
        if draftDataItem.image != nil {
            self.addImageData(image: draftDataItem.image, fileName: ref.documentID){
                // データの追加
                ref.setData(addData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref.documentID)")
                        completion()
                    }
                }
            }
        } else {
            ref.setData(addData) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref.documentID)")
                    completion()
                }
            }
        }
    }
    
    func addImageData(image: UIImage?, fileName: String, completion: @escaping (() -> ())) {
        guard let image = image, let data = image.jpegData(compressionQuality: 0.25) else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "poem/\(fileName).jpeg"
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                completion()
            }
        }
    }
}
