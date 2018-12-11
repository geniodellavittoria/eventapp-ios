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
            onSuccess(events)
        }, onError: { error in
            print(error)
        })
    }
    
    func createEvent(event: Event, completion: @escaping (Bool) -> Void) {
        post(resource: "", event, onSuccess: {
            print("Create Event successfully")
            completion(true)
        }, onError: { error in
            print(error)
            completion(false)
        })
    }
    
    func registerEvent(eventId: CLong, eventRegistration: EventRegistration, completion: @escaping (Bool) -> Void) {
        post(resource: "/" + String(eventId) + "/register", eventRegistration, onSuccess: {
            completion(true)
        }, onError: { error in
            print(error)
            completion(false)
        })
    }
}
