//
//  ViewController.swift
//  WeatherLust
//
//  Created by Neil Deramchi on 7/16/17.
//  Copyright © 2017 Neil Deramchi. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var wunderMap: MKMapView!
    var touchLatLong = String()
    var geolookupURL = String()
    
    let initialRadius: CLLocationDistance = 1000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let initialLocation = CLLocation(latitude: 36.7783, longitude: -119.4179)
        centerMapOnLocation(location: initialLocation)
        
        let wundergestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.wundermapTap(gestureRecognizer:)))
        self.wunderMap.addGestureRecognizer(wundergestureRecognizer)
            }
    
    func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, initialRadius * 1.7, initialRadius * 1.7)
            wunderMap.setRegion(coordinateRegion, animated: true)
        }
    
    func wundermapTap(gestureRecognizer: UIGestureRecognizer) {
        wunderMap.removeAnnotations(wunderMap.annotations)
        let touchPoint = gestureRecognizer.location(in: self.wunderMap)
        let touchCoordinate = wunderMap.convert(touchPoint, toCoordinateFrom: self.wunderMap)
        
        let touchLatitude = touchCoordinate.latitude
        let touchLongitude = touchCoordinate.longitude
        touchLatLong = "\(touchLatitude),\(touchLongitude)"
        geolookupURL = "http://api.wunderground.com/api/2e45071e333b24f3/geolookup/q/\(touchLatLong).json"
        print(geolookupURL)
        geoRequest()
        
        let touchAnnotation = MKPointAnnotation()
        touchAnnotation.coordinate = touchCoordinate
        
        wunderMap.addAnnotation(touchAnnotation)
        print("annotation added")
    }
    
    func geoRequest() {
        Alamofire.request(geolookupURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case.success(let value):
                let json = JSON(value)
                print("\(json)")
                let avalue = json["location"]["nearby_weather_stations"]["pws"]["station"][0]["city"].string
                print(avalue as Any)
            case.failure(let error):
                print(error)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

