//
//  CategoryController.swift
//  EventApp
//
//  Created by Pascal on 26.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Alamofire

class CategoryController : RestController {
    
    
    init() {
        super.init(resource: "categories")
    }
    
    func getCategories(onSuccess: @escaping ([Category]) -> Void, onError: @escaping (Error) -> Void) {
        super.getAll(response: Category.self, onSuccess: { categories in
            onSuccess(categories)
        }, onError: { error in
            print("Could not get any categoires")
            onError(error)
        })
    }
    
}
