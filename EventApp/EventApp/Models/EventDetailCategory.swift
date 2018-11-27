//
//  EventDetailCategory.swift
//  EventApp
//
//  Created by Pascal on 27.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation

struct EventDetailCategory: CustomStringConvertible {
    var id: Int
    var value: String
    
    init(id: Int, value: String) {
        self.id = id
        self.value = value
    }
    
    var description: String {
        //return "\(self.id)"+" "+"\(self.value)"
        return "\(self.value)"
    }
}

extension EventDetailCategory: Equatable {}

func ==(lhs: EventDetailCategory, rhs: EventDetailCategory) -> Bool {
    let areEqual = lhs.id == rhs.id &&
        lhs.value == rhs.value
    return areEqual
}
