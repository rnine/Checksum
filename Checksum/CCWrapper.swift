//
//  CCWrapper.swift
//  Checksum
//
//  Created by Ruben Nine on 12/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto


final internal class CCWrapper {

    private typealias CC_XXX_Update = (UnsafeRawPointer, CC_LONG) -> Void
    private typealias CC_XXX_Final = (UnsafeMutablePointer<UInt8>) -> Void

    public let algorithm: DigestAlgorithm

    private var digest: UnsafeMutablePointer<UInt8>?
    private var md5Ctx: CC_MD5_CTX?
    private var sha1Ctx: CC_SHA1_CTX?
    private var sha256Ctx: CC_SHA256_CTX?
    private var sha512Ctx: CC_SHA512_CTX?
    private var updateFun: CC_XXX_Update?
    private var finalFun: CC_XXX_Final?


    init(algorithm: DigestAlgorithm) {
        self.algorithm = algorithm

        switch algorithm {
        case .md5:
            var ctx = CC_MD5_CTX()

            CC_MD5_Init(&ctx)

            md5Ctx = ctx
            updateFun = { (data, len) in CC_MD5_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_MD5_Final(digest, &ctx) }

        case .sha1:
            var ctx = CC_SHA1_CTX()

            CC_SHA1_Init(&ctx)

            sha1Ctx = ctx
            updateFun = { (data, len) in CC_SHA1_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_SHA1_Final(digest, &ctx) }

        case .sha224:
            var ctx = CC_SHA256_CTX()

            CC_SHA224_Init(&ctx)

            sha256Ctx = ctx
            updateFun = { (data, len) in CC_SHA224_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_SHA224_Final(digest, &ctx) }

        case .sha256:
            var ctx = CC_SHA256_CTX()

            CC_SHA256_Init(&ctx)

            sha256Ctx = ctx
            updateFun = { (data, len) in CC_SHA256_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_SHA256_Final(digest, &ctx) }

        case .sha384:
            var ctx = CC_SHA512_CTX()

            CC_SHA384_Init(&ctx)

            sha512Ctx = ctx
            updateFun = { (data, len) in CC_SHA384_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_SHA384_Final(digest, &ctx) }

        case .sha512:
            var ctx = CC_SHA512_CTX()

            CC_SHA512_Init(&ctx)

            sha512Ctx = ctx
            updateFun = { (data, len) in CC_SHA512_Update(&ctx, data, len) }
            finalFun = { (digest) in CC_SHA512_Final(digest, &ctx) }

        }
    }

    deinit {
        digest?.deinitialize(count: algorithm.digestLength)
        digest?.deallocate()
    }

    func update(data: UnsafeMutableRawPointer, length: CC_LONG) {
        updateFun?(data, length)
    }

    func final() {
        // We already got a digest, return early
        guard digest == nil else { return }

        digest = UnsafeMutablePointer<UInt8>.allocate(capacity: algorithm.digestLength)

        if let digest = digest {
            finalFun?(digest)
        }
    }

    func hexString() -> String? {
        // We DON'T have a digest YET, return early
        guard let digest = digest else { return nil }

        var string = ""

        for i in 0..<algorithm.digestLength {
            string += String(format: "%02x", digest[i])
        }

        return string
    }
}
