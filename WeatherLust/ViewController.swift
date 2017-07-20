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
    var stationArray = [WeatherStation]()
    
    let touchAnnotation = MKPointAnnotation()
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
        stationArray.removeAll()
        let touchPoint = gestureRecognizer.location(in: self.wunderMap)
        let touchCoordinate = wunderMap.convert(touchPoint, toCoordinateFrom: self.wunderMap)
        
        let touchLatLong = "\(touchCoordinate.latitude),\(touchCoordinate.longitude)"
        let geolookupURL = "http://api.wunderground.com/api/2e45071e333b24f3/geolookup/q/\(touchLatLong).json"
        geoRequest(url: geolookupURL)
        let currentconditionslookupURL = "http://api.wunderground.com/api/2e45071e333b24f3/conditions/q/\(touchLatLong).json"
        conditionsRequest(url: currentconditionslookupURL)
        
        touchAnnotation.coordinate = touchCoordinate
        touchAnnotation.title = " "
        
        wunderMap.addAnnotation(touchAnnotation)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let zoomRegion = MKCoordinateRegion(center:touchAnnotation.coordinate, span: span)
        wunderMap.setRegion(zoomRegion, animated: true)
    }
    
    func conditionsRequest(url: String){
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                guard let currentTemp = json["current_observation"]["temp_c"].int else {
                    return
                }
                guard let currentState = json["current_observation"]["display_location"]["full"].string else {
                    return
                }
                DispatchQueue.main.async {
                    let annotationReading = currentState + " " + "\(currentTemp)" + "ºC"
                    print(annotationReading)
                    self.touchAnnotation.title = annotationReading
                    self.wunderMap.selectAnnotation(self.touchAnnotation, animated: true)
                }

            case .failure(let error):
                 print(error)
            }
          
        }

    }
    
    func geoRequest(url: String) {
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case.success(let value):
                let json = JSON(value)
                //print("\(json)")
                let responseCount = json["location"]["nearby_weather_stations"]["pws"]["station"][0].count
                print(responseCount)
                if responseCount != 0 {
                for station in 0 ..< responseCount {
                    var addStation = WeatherStation()
                    addStation.id = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["id"].string
                    addStation.latitude = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["lat"].double
                    addStation.longitude = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["lon"].double
                    addStation.mileDistance = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["distance_mi"].int
                    addStation.neighborhood = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["neighborhood"].string
                    addStation.city = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["city"].string
                    addStation.country = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["country"].string
                    addStation.state = json["location"]["nearby_weather_stations"]["pws"]["station"][station]["state"].string
                    
                    self.stationArray.append(addStation)
                }
                DispatchQueue.main.async {
                     for newstation in 0...4 {
                        if responseCount >= newstation {
                        let stationAnnotation = MKPointAnnotation()
                        guard let stationLat = self.stationArray[newstation].latitude else {
                            print("latitude missing")
                            return
                        }
                        guard let stationLon = self.stationArray[newstation].longitude else {
                            print("longitude missing")
                            return
                        }
                        stationAnnotation.coordinate = CLLocationCoordinate2D(latitude: stationLat , longitude: stationLon)
                        self.wunderMap.addAnnotation(stationAnnotation)
                    }
                    }
                }
                }
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

