//
//  UserController.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Alamofire
import JWT

class UserController : RestController<LoginForm> {
    
    init() {
        super.init(resource: "user")
    }
    
    func authenticate(loginForm: LoginForm, completion: @escaping (_ result: Bool) -> Void) {
        do {
            try super.post(resource: "authenticate", loginForm)
            .responseObject { (response: DataResponse<JwtToken>) in
                if let jwt = response.value {
                    if jwt.id_token != nil {
                        accessTokenAdapter.setAccessToken(accessToken: jwt.id_token)
                        do {
                            let claims: ClaimSet = try JWT.decode(jwt.id_token, algorithm: .hs512(Data(base64Encoded: Config.jwtSecret)!))
                            print(claims)
                            completion(true)
                        } catch {
                            print("Failed to decode JWT: \(error)")
                            completion(false)
                        }
                    }
                }
            }
        } catch  {
            print("Could not authenticate")
        }
        completion(false)
    }
    
    func register(registerForm: RegisterForm) {
        do {
            try super.post(resource: "register", registerForm)
                .responseObject { (response: DataResponse<JwtToken>) in
                    if let jwt = response.value {
                        accessTokenAdapter.setAccessToken(accessToken: jwt.id_token)
                        do {
                            let claims: ClaimSet = try JWT.decode(jwt.id_token, algorithm: .hs512(Data(base64Encoded: Config.jwtSecret)!))
                            print(claims)
                        } catch {
                            print("Failed to decode JWT: \(error)")
                        }
                    }
            }
        } catch  {
            print("Could not authenticate")
        }
    }
    
    func logout() {
        
    }
}
