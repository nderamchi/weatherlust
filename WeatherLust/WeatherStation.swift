//
//  WeatherStation.swift
//  WeatherLust
//
//  Created by Neil Deramchi on 7/17/17.
//  Copyright © 2017 Neil Deramchi. All rights reserved.
//

import UIKit
import SwiftyJSON

struct WeatherStation {
    var id : String?
    var longitude : Double?
    var latitude : Double?
    var kmDistance : Int?
    var neighborhood : String?
    var city : String?
    var state : String?
    var country : String?
    
    init() {}
}
