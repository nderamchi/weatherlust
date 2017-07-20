//
//  StationViewController.swift
//  WeatherLust
//
//  Created by Neil Deramchi on 7/19/17.
//  Copyright © 2017 Neil Deramchi. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
    @IBOutlet weak var stationDistance: UILabel!
    @IBOutlet weak var stationNeighborhood: UILabel!
}

class StationViewController: UITableViewController {
    
    var rawStationArray = [WeatherStation]()
    var stationArray = [WeatherStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //array setup
        let trimmedStationArray = rawStationArray.prefix(50)
        stationArray = trimmedStationArray.sorted{$0.neighborhood! < $1.neighborhood!}
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for:indexPath) as! StationCell
        let station = stationArray[indexPath.row]
        if let neighborhood = station.neighborhood {
            cell.stationNeighborhood?.text = neighborhood
        }
        else {
            cell.stationDistance?.text = "UNKNOWN"
        }
        if let distance = station.kmDistance {
        cell.stationDistance?.text = String(describing: distance) + "KM"
        }
        
        return cell
    }
}
