//
//  GoogleMapsView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/07/06.
//

import SwiftUI
import UIKit
import MapKit
import GoogleMaps
import GoogleMapsUtils
import FirebaseFirestore
import FirebaseStorage
import GeoFire

struct GoogleMapsRepresentable: UIViewRepresentable {
    
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @State var preciseLocationZoomLevel: Float = 15.0
    @State var approximateLocationZoomLevel: Float = 10.0
    @Binding var cardList: [Card]
    @Binding var cardID: Int
    @Binding var showFullCard: Bool
    @Binding var zoomLevel: Float
    @Binding var canVisit: Bool
    
    let mapView = GMSMapView(frame: CGRect.zero)
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(mapView: self, cardList: $cardList, cardID: $cardID, showFullCard: $showFullCard, zoomLevel: $zoomLevel, canVisit: $canVisit)
    }
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: Self.Context) -> GMSMapView {
        mapView.isHidden = true
        mapView.delegate = context.coordinator
        mapView.setMinZoom(9, maxZoom: 21)
        manager.delegate = context.coordinator
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 50
        manager.startUpdatingLocation()
        return mapView
    }
    
    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
    }
}

class Coordinator : NSObject, CLLocationManagerDelegate {
    
    var parent: GoogleMapsRepresentable
    var cluster: GMUClusterManager
    @Binding var cardList: [Card]
    @Binding var cardID: Int
    @Binding var showFullCard: Bool
    @Binding var zoomLevel: Float
    @Binding var canVisit: Bool
    private var fetchedPoint = [[Double]]()
    private var fetchDistance = 0.2
    private var fetchRange = 0.1
    private var db = Firestore.firestore()
    private var idList = [String]()
    private var fetchZoom: Float = 11.0
    private var poemViewModel = PoemViewModel()
    
    init(mapView: GoogleMapsRepresentable, cardList: Binding<[Card]>, cardID: Binding<Int>, showFullCard: Binding<Bool>, zoomLevel: Binding<Float>, canVisit: Binding<Bool>) {
        parent = mapView
        // 現在位置に戻るボタンの表示
        parent.mapView.settings.myLocationButton = true
        // 現在位置の青い丸の表示
        parent.mapView.isMyLocationEnabled = true
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: parent.mapView, clusterIconGenerator: iconGenerator)
        renderer.minimumClusterSize = 2
        cluster = GMUClusterManager(map: parent.mapView, algorithm: algorithm, renderer: renderer)
        // Map にマーカーを描画
        cluster.cluster()
        _cardList = cardList
        _cardID = cardID
        _showFullCard = showFullCard
        _zoomLevel = zoomLevel
        _canVisit = canVisit
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            parent.alert = false
        case .notDetermined, .denied, .restricted:
            parent.alert = true
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        let zoomLevel = manager.accuracyAuthorization == .fullAccuracy ? parent.preciseLocationZoomLevel : parent.approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if parent.mapView.isHidden {
            parent.mapView.isHidden = false
            parent.mapView.camera = camera
        } else {
            parent.mapView.clear()
            parent.mapView.animate(to: camera)
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if [.notDetermined, .denied, .restricted].contains(status) {
            parent.alert = true
        }
        print("Error: \(error)")
    }
    
    func fetchData(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInM: Double = 15 * 1000
        
        let queryBounds = GFUtils.queryBounds(forLocation: location,
                                              withRadius: radiusInM)
        let queries = queryBounds.map { bound -> Query in
            return db.collection("poem")
                .order(by: "geoHash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            for document in documents {
                let data = document.data()
                let title = data["title"] as? String ?? ""
                let star = data["star"] as? Int ?? 0
                let description = data["text"] as? String ?? ""
                let author = data["author"] as? String ?? ""
                let authorID = data["author_id"] as? String ?? ""
                let hasImage = data["image"] as? Bool ?? false
                let documentID = document.documentID
                let tag: [String] = data["tag"] as? [String] ?? []
                let place = data["place"] as? GeoPoint
                let latitude = place!.latitude
                let longitude = place!.longitude
                let isHorizontal = data["isHorizontal"] as? Bool ?? true
                
                if self.idList.contains(documentID) {
                    return
                }
                self.idList.append(documentID)
                
                let processedDescription = descriptionProcess(rawDescription: description)
                var inputCard = Card(iconImage: UIImage(named:"logo")!, title: title, star: star, description: processedDescription, author:author, authorID: authorID, tag:tag, hasImage: hasImage, documentID: documentID, latitude: latitude, longitude: longitude, isHorizontal: isHorizontal)
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(latitude, longitude))
                marker.title = String(self.cardList.count)
                self.cardList.append(inputCard)
                let inputCardId = self.cardList.count - 1
                if hasImage{
                    inputCard.iconImage = UIImage(named: "logo")!
                    let url = "poem/\(documentID).jpeg"
                    downloadImageAsync(url: url) { image in
                        self.cardList[inputCardId].iconImage = image!
                    }
                }
                poemViewModel.getAuthorName(input: self.cardList[inputCardId]) { authorName in
                    self.cardList[inputCardId].author = authorName
                }
                self.cluster.add(marker)
                self.cluster.cluster()
            }
        }
        
        for query in queries {
            query.getDocuments(completion: getDocumentsCompletion)
        }
        
    }
}

extension Coordinator : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let title = marker.title else {
            return nil
        }
        let hosting = UIHostingController(rootView: MiniCardView(input: self.cardList[Int(title)!]))
        hosting.view.frame = CGRect(x: 0, y: 0, width: 220, height: 140)
        hosting.view.layer.cornerRadius = 16
        hosting.view.backgroundColor = UIColor.clear
        hosting.view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        // 影の色
        hosting.view.layer.shadowColor = UIColor.black.cgColor
        // 影の濃さ
        hosting.view.layer.shadowOpacity = 0.8
        // 影をぼかし
        hosting.view.layer.shadowRadius = 5
        return hosting.view
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let newPoint = [position.target.latitude, position.target.longitude]
        zoomLevel = self.parent.mapView.camera.zoom
        
        if self.parent.mapView.camera.zoom < fetchZoom {
            return
        }
        // 配列の長さが0でも分岐に入る
        // allSatisfyに短絡評価を期待しているが万が一短絡評価をしない or 配列を頭から見ない場合は対応が必要
        if fetchedPoint.allSatisfy({ calcChebyshev(aPoint: $0, bPoint: newPoint) > fetchRange }){
            fetchedPoint.append(newPoint)
            fetchedPoint.insert(newPoint, at: 0)
            fetchData(latitude: newPoint[0], longitude: newPoint[1])
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let coordinate = (mapView.myLocation?.coordinate)!
        let distance = marker.position.distance(to: coordinate)
        canVisit = distance < 100
        cardID = Int(marker.title!)!
        showFullCard = true
    }
    
    func calcChebyshev(aPoint: [Double], bPoint: [Double]) -> Double{
        return max(abs(aPoint[0] - bPoint[0]), abs(aPoint[1] - bPoint[1]))
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
}


class POIItem: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var title: NSString
    
    init(position: CLLocationCoordinate2D, title: NSString) {
        self.position = position
        self.title = title
    }
}
