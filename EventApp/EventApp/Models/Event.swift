//
//  Event.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import UIKit

struct Event: Codable {
    var id: CLong?
    var name: String
    var description: String?
    var longitude: Double?
    var latitude: Double?
    var price: Double?
    var timestamp: Date?
    var eventStart: Date?
    var eventEnd: Date?
    var eventImage: String?
    var category: Category?
    //var impression: [UIImage]?
    
    init(name: String) {
        self.name = name
    }
}
