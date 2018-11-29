//
//  DictionaryEncoder.swift
//  EventApp
//
//  Created by Pascal on 28.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation

class DictionaryEncoder {
    
    static func getModelFromDict<T: Decodable>(dict: [String: Any?], res: T.Type, onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) {
        let decoder = JSONDecoder()
        do {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                let model = try? decoder.decode(res.self, from: jsonData) else {
                    print("err")
                    onError(encodingError.jsonSerializationError)
                    return
            }
            onSuccess(model)
        }
        
    }
}

enum encodingError: Error {
    case jsonSerializationError
}
