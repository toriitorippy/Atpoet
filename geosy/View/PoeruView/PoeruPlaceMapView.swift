//
//  PoeruPlaceMapView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/17.
//

import SwiftUI
import UIKit
import MapKit
import GoogleMaps

struct PoeruPlaceMapView: UIViewRepresentable {
    
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var hasPin : Bool
    @Binding var latitude : Double
    @Binding var longitude : Double
    @State var preciseLocationZoomLevel: Float = 18.0
    @State var approximateLocationZoomLevel: Float = 18.0
    
    let mapView = GMSMapView(frame: CGRect.zero)
    
    func makeCoordinator() -> PoeruCoordinator {
        // ズームなどのジェスチャーの禁止
        mapView.settings.setAllGesturesEnabled(false)
        // 現在位置の青い丸の表示
        mapView.isMyLocationEnabled = true
        return PoeruCoordinator(parentView: self, hasPin: $hasPin, latitude: $latitude, longitude: $longitude)
    }
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: Self.Context) -> GMSMapView {
        mapView.isHidden = true
        mapView.delegate = context.coordinator
        manager.delegate = context.coordinator
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 10
        manager.startUpdatingLocation()
        mapView.preferredFrameRate = .conservative
        return mapView
    }
    
    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
    }
}

class PoeruCoordinator : NSObject, CLLocationManagerDelegate {
    
    @Binding var hasPin : Bool
    @Binding var latitude : Double
    @Binding var longitude : Double
    var parent: PoeruPlaceMapView
    var timer: Timer?
    let marker = GMSMarker()
    
    init(parentView: PoeruPlaceMapView, hasPin: Binding<Bool>, latitude: Binding<Double>, longitude: Binding<Double>) {
        parent = parentView
        // ズームなどのジェスチャーの禁止
        parent.mapView.settings.setAllGesturesEnabled(false)
        // 現在位置の青い丸の表示
        parent.mapView.isMyLocationEnabled = true
        _hasPin = hasPin
        _latitude = latitude
        _longitude = longitude
        
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
//        print("Location: \(location)")
        let zoomLevel = manager.accuracyAuthorization == .fullAccuracy ? parent.preciseLocationZoomLevel : parent.approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if parent.mapView.isHidden {
            parent.mapView.isHidden = false
            parent.mapView.camera = camera
            let overlayView = UIView(frame: parent.mapView.bounds)
            overlayView.layer.mask = nil
            overlayView.tag = 1
            overlayView.alpha = 0.4
            overlayView.backgroundColor = .black
            overlayView.isUserInteractionEnabled = false
            parent.mapView.addSubview(overlayView)
            startTimer()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    //MARK: Timer
    // タイマー開始
    func startTimer() {
        _update()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PoeruCoordinator.update), userInfo: nil, repeats: true)
    }
    
    @objc func update(timer: Timer) {
        _update()
    }
    func _update(){
        //GoogleMAPが取得している位置を取得
        if let mylocation = parent.mapView.myLocation {
            //カメラを現在地に
            let update = GMSCameraUpdate.setTarget(mylocation.coordinate)
            parent.mapView.moveCamera(update)
            //アニメーションにするとカクカクするのでアニメーションなしのUpdate
            let point = parent.mapView.projection.point(for: CLLocationCoordinate2D(latitude: mylocation.coordinate.latitude, longitude: mylocation.coordinate.longitude))
//            print("the screen coordinate: \(mylocation.coordinate.latitude) \(mylocation.coordinate.latitude)")
            for subview in parent.mapView.subviews {
                if subview.tag == 1 {
                    subview.layer.mask = nil
                    createHole(overlayView :subview, holeX: point.x, holeY: point.y, radius: 200)
                }
            }
        }
        
    }
}

extension PoeruCoordinator : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        if parent.mapView.myLocation!.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < 100{
            marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            latitude = Double(coordinate.latitude)
            longitude = Double(coordinate.longitude)
            hasPin = true
            marker.map = parent.mapView
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return true
    }
    
    func createHole(overlayView : UIView, holeX : CGFloat, holeY : CGFloat, radius: CGFloat)
    {
        let maskLayer = CAShapeLayer()
        
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: holeX, y: holeY),
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi) * 2,
                    clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        maskLayer.backgroundColor = UIColor.black.cgColor
        
        maskLayer.path = path;
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
    }
}
