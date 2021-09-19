//
//  MasterPoeruPlaceMapView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/17.
//

import SwiftUI
import UIKit
import MapKit
import GoogleMaps

struct MasterPoeruPlaceMapView: UIViewRepresentable {
    
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var hasPin : Bool
    @Binding var latitude : Double
    @Binding var longitude : Double
    @State var preciseLocationZoomLevel: Float = 18.0
    @State var approximateLocationZoomLevel: Float = 18.0
    
    let mapView = GMSMapView(frame: CGRect.zero)
    
    func makeCoordinator() -> MasterPoeruCoordinator {
        // 現在位置の青い丸の表示
        mapView.isMyLocationEnabled = true
        return MasterPoeruCoordinator(parentView: self, hasPin: $hasPin, latitude: $latitude, longitude: $longitude)
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

class MasterPoeruCoordinator : NSObject, CLLocationManagerDelegate {
    
    @Binding var hasPin : Bool
    @Binding var latitude : Double
    @Binding var longitude : Double
    var parent: MasterPoeruPlaceMapView
    var timer: Timer?
    let marker = GMSMarker()
    
    init(parentView: MasterPoeruPlaceMapView, hasPin: Binding<Bool>, latitude: Binding<Double>, longitude: Binding<Double>) {
        parent = parentView
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
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Error: \(error)")
    }
        
}

extension MasterPoeruCoordinator : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
            marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            latitude = Double(coordinate.latitude)
            longitude = Double(coordinate.longitude)
            hasPin = true
            marker.map = parent.mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return true
    }
}
