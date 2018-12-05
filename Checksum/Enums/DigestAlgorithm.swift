//
//  DigestAlgorithm.swift
//  Checksum
//
//  Created by Ruben Nine on 12/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto.CommonDigest

public enum DigestAlgorithm {
    case md5
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512

    public var digestLength: Int {
        switch self {
        case .md5: return Int(CC_MD5_DIGEST_LENGTH)
        case .sha1: return Int(CC_SHA1_DIGEST_LENGTH)
        case .sha224: return Int(CC_SHA224_DIGEST_LENGTH)
        case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
        case .sha384: return Int(CC_SHA384_DIGEST_LENGTH)
        case .sha512: return Int(CC_SHA512_DIGEST_LENGTH)
        }
    }
}
