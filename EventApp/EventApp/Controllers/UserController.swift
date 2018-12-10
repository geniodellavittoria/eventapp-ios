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

class UserController : RestController {
    
    init() {
        super.init(resource: "user")
    }
    
    func authenticate(loginForm: LoginForm, completion: @escaping (_ result: Bool) -> Void) {
        
        super.post(resource: "authenticate", loginForm, response: JwtToken.self, onSuccess: { (response) in
            print("usercontroller")
            if response.id_token != nil {
                accessTokenAdapter.setAccessToken(accessToken: response.id_token)
                do {
                    let claims: ClaimSet = try JWT.decode(response.id_token, algorithm: .hs512(Data(base64Encoded: Config.jwtSecret)!))
                    authService.userId = claims["user_id"] as? CLong
                    print(claims)
                    print(authService.userId as Any)
                    completion(true)
                } catch {
                    print("Failed to decode JWT: \(error)")
                    completion(false)
                }
            }
            print(response.id_token)
            completion(false)
            /*if let jwt = response.value {
             
             }*/
        }, onError: { error in
            print("Could not authenticate")
        })
    }
    
    func register(registerForm: RegisterForm, completion: @escaping (Bool) -> Void) {
        
        super.post(resource: "register", registerForm, response: JwtToken.self, onSuccess: { response in
            completion(true)
        }, onError: { error in
            print("Could not register")
            completion(false)
        })
        
    }
    
    func logout() {
        
    }
}
