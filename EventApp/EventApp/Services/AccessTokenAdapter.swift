//
//  AuthorizationFilter.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Alamofire

let accessTokenAdapter = AccessTokenAdapter()

class AccessTokenAdapter: RequestAdapter {
    private var accessToken: String = ""
        
    func setAccessToken(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(Config.backendUrl) {
            if accessToken != "" {
                urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }
        }
        
        return urlRequest
    }
}
