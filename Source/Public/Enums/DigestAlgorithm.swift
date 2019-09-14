//
//  DigestAlgorithm.swift
//  Checksum
//
//  Created by Ruben Nine on 12/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import CommonCrypto.CommonDigest
import Foundation

/// Represents a type of digest algorithm.
public enum DigestAlgorithm {
    /// MD5 algorithm.
    case md5

    /// SHA1 algorithm.
    case sha1

    /// SHA224 algorithm.
    case sha224

    /// SHA256 algorithm.
    case sha256

    /// SHA384 algorithm.
    case sha384

    /// SHA512 algorithm.
    case sha512
}

extension DigestAlgorithm {
    internal var digestLength: Int {
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
