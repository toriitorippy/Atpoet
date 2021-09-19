//
//  PostedMapView.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/17.
//

import SwiftUI
import UIKit
import MapKit
import GoogleMaps

struct PostedMapView: UIViewRepresentable {

    var latitude : Double
    var longitude : Double
    var allowGesture: Bool
    @State var preciseLocationZoomLevel: Float = 18.0
    @State var approximateLocationZoomLevel: Float = 18.0
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: preciseLocationZoomLevel)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        // ズームなどのジェスチャーの禁止
        mapView.settings.setAllGesturesEnabled(allowGesture)
        mapView.preferredFrameRate = .conservative
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = mapView
        return mapView
    }
    
    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
    }
}
