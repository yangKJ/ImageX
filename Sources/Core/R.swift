//
//  R.swift
//  ImageX
//
//  Created by Condy on 2023/3/7.
//

import Foundation
import Harbeth

extension R {
    
    /// Read gif data.
    public static func gifData(_ named: String, forResource: String = "ImageX") -> Data? {
        let bundle: Bundle?
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: "bundle") {
            bundle = Bundle.init(path: bundlePath)
        } else {
            bundle = Bundle.main
        }
        guard let contentURL = ["gif", "GIF", "Gif"].compactMap({
            bundle?.url(forResource: named, withExtension: $0)
        }).first else {
            return nil
        }
        return try? Data(contentsOf: contentURL)
    }
    
    /// Verify that the URL format is correct.
    public static func verifyLink(_ str: String) -> Bool {
        do {
            let dataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let options = NSRegularExpression.MatchingOptions(rawValue: 0)
            let res = dataDetector.matches(in: str, options: options, range: NSMakeRange(0, str.count))
            if res.count == 1 && res[0].range.location == 0 && res[0].range.length == str.count {
                return true
            }
        } catch { }
        return false
    }
}
