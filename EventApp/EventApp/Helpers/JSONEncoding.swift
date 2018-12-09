//
//  JSONEncoding.swift
//  EventApp
//
//  Created by Pascal on 30.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import UIKit

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

/*extension UIImage {
    convenience init?(base64 str: String) {
        guard let data = try? Data(base64Encoded: str),
            UIImage(data: data) != nil else { return nil }
        self.init(data: data)!
    }
}*/
extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
