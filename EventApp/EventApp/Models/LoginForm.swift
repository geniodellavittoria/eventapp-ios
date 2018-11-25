//
//  LoginForm.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Validator

public class LoginForm : Codable {
    var username: String?
    var password: String?
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /*enum ValidationErrors: String, Error {
        case emailInvalid = "Email address is invalid"
        var message { return self.rawValue }
    }
    
    func validate() -> ValidationResult {
        let rule = ValidationRulePattern(pattern: .required, ValidationErrors.usernameRequired)
        let rule ValidationRulePattern(pattern: .emailAddress, error: ValidationErrors.emailInvalid)
        return email.validate(rule: rule)
    }*/
}
