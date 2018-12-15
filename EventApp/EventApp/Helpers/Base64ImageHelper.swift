//
//  Base64Helper.swift
//  EventApp
//
//  Created by Pascal on 13.12.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import UIKit

class Base64ImageHelper {
    
    static func getBase64DecodedImage(_ data: String?) -> UIImage {
        if (data == nil) {
            return UIImage()
        }
        let decodedData = Data(base64Encoded: data!, options: NSData.Base64DecodingOptions(rawValue: 0))
        
        if let decodedData = decodedData as? Data {
            if !decodedData.isEmpty {
                return UIImage(data: decodedData)!
            }
        }
        return UIImage()
    }
    
    static func encodingImage(_ image: UIImage?) -> String {
        if let convertedImage = image as? UIImage {
            return convertedImage.toBase64() as? String ?? ""
        }
        return "";
    }
}
