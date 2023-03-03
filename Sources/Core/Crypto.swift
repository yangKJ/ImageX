//
//  Crypto.swift
//  Wintersweet
//
//  Created by Condy on 2023/3/2.
//

import Foundation
import CommonCrypto

public struct Crypto {
    public struct MD5 { }
}

extension Crypto.MD5 {
    /// MD5
    public static func md5(string: String) -> String {
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
}
