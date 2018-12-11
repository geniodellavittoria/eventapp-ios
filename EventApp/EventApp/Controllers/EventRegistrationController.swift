//
//  EventRegistrationController.swift
//  EventApp
//
//  Created by Pascal on 11.12.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Alamofire

class EventRegistrationController : RestController {
    
    init() {
        super.init(resource: "registrations")
    }
    
    func getEventRegistrations(onSuccess: @escaping ([EventRegistration]) -> Void, onError: @escaping ([Error]) -> Void) {
        
    }
    
    func getTaggingEventRegistrations(onSuccess: @escaping ([EventRegistration]) -> Void, onError: @escaping (Error) -> Void) {
        getAll(resource: "tagging", response: EventRegistration.self, onSuccess: { eventRegistrations in
            onSuccess(eventRegistrations)
        }, onError: { error in
            print(error)
            onError(error)
        })
    }
}
