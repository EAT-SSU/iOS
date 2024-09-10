//
//  RestaurantLocation.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/24.
//

import Foundation
import CoreLocation
import MapKit

enum RestaurantLocation {
    case dormitory
    case dodam
    case studentRestaurant
    case foodCourt
    case snackCorner
    case soongsil
    
    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .dormitory:
            return CLLocationCoordinate2D(latitude: 37.4951, longitude: 126.9603)
        case .dodam:
            return CLLocationCoordinate2D(latitude: 37.4961, longitude: 126.9581)
        case .studentRestaurant:
            return CLLocationCoordinate2D(latitude: 37.4964, longitude: 126.9572)
        case .foodCourt:
            return CLLocationCoordinate2D(latitude: 37.4964, longitude: 126.9572)
        case .snackCorner:
            return CLLocationCoordinate2D(latitude: 37.4964, longitude: 126.9572)
        case .soongsil:
            return CLLocationCoordinate2D(latitude: 37.4964, longitude: 126.9572)
        }
    }
    
    var title: String {
        switch self {
        case .dormitory:
            return TextLiteral.dormitoryRestaurant
        case .dodam:
            return TextLiteral.dodamRestaurant
        case .studentRestaurant:
            return TextLiteral.studentRestaurant
        case .foodCourt:
            return TextLiteral.foodCourt
        case .snackCorner:
            return TextLiteral.snackCorner
        case .soongsil:
            return "숭실대학교"
        }
    }
}

func setMapView(mapView: MKMapView, for location: RestaurantLocation) {
    let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
    
    // Set the region on the map view
    mapView.setRegion(region, animated: true)
    
    // Create a point annotation
    let annotation = MKPointAnnotation()
    // Set the coordinate of the annotation to be the location
    annotation.coordinate = location.coordinate
    // Optionally, add a title to the annotation
    annotation.title = location.title
    // Add the annotation to the map view
    mapView.addAnnotation(annotation)
    
}
