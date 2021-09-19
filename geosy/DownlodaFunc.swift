import Firebase
import FirebaseStorage

//　画像の非同期処理
public func downloadImageAsync(url: String, completion: @escaping (UIImage?) -> Void) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imafeRef = storageRef.child(url)
    imafeRef.getData(maxSize: 10 * 4048 * 4048) { data, error in
        var image: UIImage?
        if let data = data {
            image = UIImage(data: data)
        }else{
            print(error)
        }
        DispatchQueue.main.async {
            completion(image)
        }
    }
}
