//
//  EventController.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//


class EventController : RestController {
    
    init() {
        super.init(resource: "events")
    }
    
    func getEvents(onSuccess: @escaping ([Event]) -> Void, onError: @escaping (Error) -> Void) {
        getAll(response: Event.self, onSuccess: { events in
            print(events)
        }, onError: { error in
            print(error)
        })
    }
}
