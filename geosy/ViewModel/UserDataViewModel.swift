//
//  UserData.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/08/24.
//

import Foundation
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseFirestore

//fileprivate let clientID = "<clientID>"    // https://console.cloud.google.com/ API -> Credential

class UserData: NSObject, ObservableObject {
    override init(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        signInConfig = GIDConfiguration(clientID: clientID)
    }
    
    @Published var user: GIDGoogleUser?
    @Published var database_user = User()
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
    @Published var isFirst: Bool = false
    @Published var isfetched: Bool = false
    @Published var register_status: Int = 0
    @Published var bookmarks = [String]()
    @Published var visiteds = [String]()
    @Published var follow = [String]()
    @Published var follower = [String]()
    
    private var db = Firestore.firestore()
    
    var signInConfig: GIDConfiguration?
    
    func fetchMyUserData () { //データベースのユーザー情報を取得
        if Auth.auth().currentUser != nil { //ログイン状態の時のみ
            let currentuser = Auth.auth().currentUser
            if let currentuser = currentuser {
                fetchUserData(uid: currentuser.uid){ User in
                    print("change here")
                    self.fetchFollowerData(uid: self.database_user.id){ follower in
                        self.database_user.follower = follower
                        for (k, _follower) in self.database_user.follower {
                            downloadImageAsync(url: _follower.imageUrl) { image in
                                if let image = image{
                                    self.database_user.follower[k]?.image = image
                                }
                            }
                        }
                    }
                    self.fetchFollowData(uid: self.database_user.id){ follow in
                        self.database_user.follow = follow
                        for (k, _follow) in self.database_user.follow {
                            downloadImageAsync(url: _follow.imageUrl) { image in
                                if let image = image{
                                    self.database_user.follow[k]?.image = image
                                }
                            }
                        }
                    }
                }
                
                downloadImageAsync(url: database_user.image_url) { image in
                    if let image = image{
                        self.database_user.image = image
                    }
                }
            }
        } else {
            self.isfetched = true
        }
    }
    
    func fetchUserData(uid: String, completion: @escaping ((User) -> ())) {
        let userRef = db.collection("users").document(uid)
        userRef.addSnapshotListener { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("No documents")
                return
            }
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            if dataDescription == "nil" {
                // ユーザー情報が登録されていない
                self.database_user = User(id: uid, name: "")
                self.isSignedIn = false
                self.isFirst = true
                self.isfetched = true
            } else {
                let name = document.data()?["name"] as? String ?? ""
                let image_url = document.data()?["image_url"] as? String ?? ""
                let body_text = document.data()?["body_text"] as? String ?? ""
                self.database_user.name = name
                self.database_user.image_url = image_url
                self.database_user.bodytext = body_text
                print(uid)
                self.database_user.id = uid
                self.isSignedIn = true
                self.isfetched = true
                self.bookmarks = document.data()?["bookmark"] as? [String] ?? [""]
                self.visiteds = document.data()?["visited"] as? [String] ?? [""]
                self.follow = document.data()?["follow"] as? [String] ?? [""]
                self.follower = document.data()?["follower"] as? [String] ?? [""]
                completion(self.database_user)
            }
        }
    }
    
    func fetchFollowerData(uid: String, completion: @escaping (([String: User]) -> ())){
        fetchFollowFollowerData(uid: uid, follow: "follow", completion: completion)
    }
    
    func fetchFollowData(uid: String, completion: @escaping (([String: User]) -> ())){
        fetchFollowFollowerData(uid: uid, follow: "follower", completion: completion)
    }
    
    func fetchFollowFollowerData(uid: String, follow: String, completion: @escaping (([String: User]) -> ())){
        var follower = [String: User]()
        let userRef = db.collection("users")
        
        let orderdref = userRef
            .whereField(follow, arrayContains: uid)
        
        orderdref.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            for document in documents {
                let data = document.data()
                let documentID = document.documentID
                let name = data["name"] as? String ?? ""
                let image_url = data["image_url"] as? String ?? ""
                let body_text = data["body_text"] as? String ?? ""
                follower.updateValue(User(id: documentID, name: name, bodytext: body_text, imageUrl: image_url, documentID: documentID), forKey: documentID)
            }
            completion(follower)
        }
    }
    
    func signIn(user: GIDGoogleUser?) {
        self.user = user
        
        guard let user = user, let imageURL = user.profile?.imageURL(withDimension: 50) else {
            return
        }
        
        guard
            let authentication = self.user?.authentication,
            let idToken = authentication.idToken
        else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            self.fetchMyUserData()
        }
    }
    
    func addUserName(name: String, completion: @escaping (() -> ())) {
        let uid = database_user.id
        db.collection("users").document(uid).setData([
            "name": name,
            "image_url": "atpoet_users/" + database_user.id + ".jpeg",
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                completion()
            }
        }
    }
    
    func addImageData(image: UIImage?, fileName: String, completion: @escaping (() -> ())) {
        guard let image = image, let data = image.jpegData(compressionQuality: 0.25) else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "atpoet_users/\(fileName).jpeg"
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = imageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                completion()
                print(downloadURL)
            }
        }
    }
    
    func updateUserInfo(id: String, name:String, body_text: String, completion: @escaping (() -> ())) {
        self.db.collection("users").document(id).setData([
            "name": name,
            "image_url": "atpoet_users/" + id + ".jpeg",
            "body_text": body_text,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                completion()
            }
        }
    }
    
    func updateUserImage(image: UIImage?, fileName: String, completion: @escaping (() -> ())) {
        // 画像のアップデート
        guard let image = image, let data = image.jpegData(compressionQuality: 0.25) else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "atpoet_users/\(fileName).jpeg"
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = imageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print(downloadURL)
                completion()
            }
        }
    }
    
    func doBookmark(document: String) {
        db.collection("users").document(database_user.id).updateData([
            "bookmark": FieldValue.arrayUnion([document])
        ])
        db.collection("poem").document(document).updateData([
            "bookmark_id": FieldValue.arrayUnion([database_user.id])
        ])
    }
    
    func undoBookmark(document: String) {
        db.collection("users").document(database_user.id).updateData([
            "bookmark": FieldValue.arrayRemove([document])
        ])
        db.collection("poem").document(document).updateData([
            "bookmark_id": FieldValue.arrayRemove([database_user.id])
        ])
    }
    
    func doVisited(document: String) {
        db.collection("users").document(database_user.id).updateData([
            "visited": FieldValue.arrayUnion([document])
        ])
        db.collection("poem").document(document).updateData([
            "visit_id": FieldValue.arrayUnion([database_user.id])
        ])
    }
    
    func undoVisited(document: String) {
        db.collection("users").document(database_user.id).updateData([
            "visited": FieldValue.arrayRemove([document])
        ])
        db.collection("poem").document(document).updateData([
            "visit_id": FieldValue.arrayUnion([database_user.id])
        ])
    }
    
    func doFollow(user_id: String) {
        db.collection("users").document(database_user.id).updateData([
            "follow": FieldValue.arrayUnion([user_id])
        ])
        db.collection("users").document(user_id).updateData([
            "follower": FieldValue.arrayUnion([database_user.id])
        ])
    }
    
    func undoFollow(user_id: String) {
        db.collection("users").document(database_user.id).updateData([
            "follow": FieldValue.arrayRemove([user_id])
        ])
        db.collection("users").document(user_id).updateData([
            "follower": FieldValue.arrayRemove([database_user.id])
        ])
    }
}
