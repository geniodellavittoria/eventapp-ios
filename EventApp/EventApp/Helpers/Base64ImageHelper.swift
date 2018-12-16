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
    //
    // Convert UIImage to a base64 representation
    //
    class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    //
    // Convert a base64 representation to a UIImage
    //
    class func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
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



extension UIImage {
    
    func convertToBase64() -> String {
        return self.toBase64() as? String ?? ""
    }
    
    
}
