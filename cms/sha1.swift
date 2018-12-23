//
//  sha1.swift
//  cms
//
//  Created by Andrey on 23/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

func sha1(_ string: String) -> String {
    let data = string.data(using: String.Encoding.utf8)!
    var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA1($0, CC_LONG(data.count), &digest)
    }
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
}
