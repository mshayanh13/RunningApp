//
//  CustomAnnotation.swift
//  RunningApp
//
//  Created by Mohammad Shayan on 4/29/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let coordinateType: CoordinateType
    
    init(coordinateType: CoordinateType, coordinate: CLLocationCoordinate2D) {
        self.coordinateType = coordinateType
        self.title = coordinateType == .start ? "Starting Point" : "Ending Point"
        self.subtitle = coordinateType == .start ? "This is where you started" : "This is where you ended"
        self.coordinate = coordinate
    }
}

enum CoordinateType {
    case start
    case end
}
