//
//  FormValidation.swift
//  EventApp
//
//  Created by Pascal on 25.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Eureka

class FormValidation {
    
    static func validateField(cell: TextCell, row: TextRow) {
        if !row.isValid {
            cell.titleLabel?.textColor = .red
            
            var errors = ""
            
            for error in row.validationErrors {
                let errorString = error.msg + "\n"
                errors = errors + errorString
            }
            print(errors)
            cell.textField.placeholder = ""
            cell.detailTextLabel?.text = errors
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.textAlignment = .left
        }
    }
}

enum FormValidationError: Error {
    case requiredFieldError
    case invalidEmailError
    case tooShortTextError
}
