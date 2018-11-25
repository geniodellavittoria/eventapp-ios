//
//  JwtToken.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//


struct JwtToken : Codable {
    var id_token: String!
    
    init(id_token: String) {
        self.id_token = id_token
    }
}
