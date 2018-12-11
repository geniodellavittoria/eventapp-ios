//
//  SettingsController.swift
//  EventApp
//
//  Created by Pascal on 29.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation

class SettingsController: FormViewController{

    var gpsEnabled = true
    let gps = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< SwitchRow("locationSwitchTag") {
                $0.title = "GPS enabled"
                $0.value = gpsEnabled
                }.onChange({ (row) in
                    if (row.value == false){
                        self.gps.stopTracking()
                    }
                    else{
                        self.gps.startTracking()
                    }
                })
            <<< LocationRow(){
                $0.hidden = Condition.function(["locationSwitchTag"], { form in
                    return !((form.rowBy(tag: "locationSwitchTag") as? SwitchRow)?.value ?? true)
                    })
                $0.tag = "location"
                $0.title = "Location"
                $0.value = CLLocation(latitude: -34.91, longitude: -56.1646)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
        }
        
    }

}
