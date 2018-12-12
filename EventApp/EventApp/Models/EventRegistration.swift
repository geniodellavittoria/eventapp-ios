//
//  EventRegistration.swift
//  EventApp
//
//  Created by Pascal on 11.12.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation

struct EventRegistration : Codable {
    var timestamp: Date?
    var eventRegistrationId: CLong?
    var userId: CLong?
    var eventId: CLong?
}
