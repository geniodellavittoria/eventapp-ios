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
    
    func getCategories() -> [Category] {
        do {
            try super.getAll()
                .responseObject { (response: DataResponse<[Category]>) in
                    
                    if let categories = response.value {
                        //return categories
                    }
            }
        } catch  {
            print("Could not authenticate")
        }
        return []
        //completion([])
    }
    
}
