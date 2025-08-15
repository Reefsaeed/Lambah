//
//  MapService.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import UIKit
import MapKit

class MapService {
    
    static func findNearestService() {
        let searchQuery = "car service center"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "car+service"
        
        if let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedQuery)&directionsmode=driving") {
            if UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL, options: [:]) { success in
                    if !success {
                        openGoogleMapsWeb(query: encodedQuery)
                    }
                }
            } else {
                openGoogleMapsWeb(query: encodedQuery)
            }
        } else {
            fallbackToAppleMaps(query: searchQuery)
        }
    }
    
    private static func openGoogleMapsWeb(query: String) {
        if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)") {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            fallbackToAppleMaps(query: query)
        }
    }
    
    private static func fallbackToAppleMaps(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MKCoordinateRegion(.world)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, !response.mapItems.isEmpty else {
                MKMapItem.openMaps(with: [MKMapItem.forCurrentLocation()], launchOptions: nil)
                return
            }
            
            let firstItem = response.mapItems.first!
            let currentLocation = MKMapItem.forCurrentLocation()
            
            MKMapItem.openMaps(with: [currentLocation, firstItem],
                              launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}
