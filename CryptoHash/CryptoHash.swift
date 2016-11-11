//
//  CryptoHash.swift
//  CryptoHash
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto

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

private let defaultChunkSize = 4096

// MARK: - Public Extensions

public extension URL {
    func cryptoHash(algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        return try CCUtils.calculateHash(url: self, algorithm: algorithm, chunkSize: chunkSize)
    }
}

public extension String {
    func cryptoHash(algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        return try CCUtils.calculateHash(string: self, algorithm: algorithm, chunkSize: chunkSize)
    }
}

public extension Data {
    func cryptoHash(algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        return try CCUtils.calculateHash(data: self, algorithm: algorithm, chunkSize: chunkSize)
    }
}

// MARK: - CCUtils (for internal use)

private class CCUtils {

    static func calculateHash(url: URL, algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        return try calculateHash(data: data, algorithm: algorithm, chunkSize: chunkSize)
    }

    static func calculateHash(string: String, algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        if let data = string.data(using: .utf8) {
            return try calculateHash(data: data, algorithm: algorithm, chunkSize: chunkSize)
        } else {
            return nil
        }
    }

    static func calculateHash(data: Data, algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {
        let cc = CCWrapper(algorithm: algorithm)
        var bytesLeft = data.count

        data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            var uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)

            while bytesLeft > 0 {
                let bytesToCopy = min(bytesLeft, chunkSize)

                cc.update(data: uMutablePtr, length: CC_LONG(bytesToCopy))

                bytesLeft -= bytesToCopy
                uMutablePtr += bytesToCopy
            }
        }

        cc.final()
        return cc.hexString()
    }
}

// MARK: - CCWrapper (for internal use)

private class CCWrapper {

    public let algorithm: DigestAlgorithm

    private var digest: UnsafeMutablePointer<UInt8>?
    private var md5Ctx: UnsafeMutablePointer<CC_MD5_CTX>?
    private var sha1Ctx: UnsafeMutablePointer<CC_SHA1_CTX>?
    private var sha256Ctx: UnsafeMutablePointer<CC_SHA256_CTX>?
    private var sha512Ctx: UnsafeMutablePointer<CC_SHA512_CTX>?


    init(algorithm: DigestAlgorithm) {
        self.algorithm = algorithm

        switch algorithm {
        case .md5:
            md5Ctx = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: algorithm.digestLength)
            CC_MD5_Init(md5Ctx)
        case .sha1:
            sha1Ctx = UnsafeMutablePointer<CC_SHA1_CTX>.allocate(capacity: algorithm.digestLength)
            CC_SHA1_Init(sha1Ctx)
        case .sha224:
            sha256Ctx = UnsafeMutablePointer<CC_SHA256_CTX>.allocate(capacity: algorithm.digestLength)
            CC_SHA224_Init(sha256Ctx)
        case .sha256:
            sha256Ctx = UnsafeMutablePointer<CC_SHA256_CTX>.allocate(capacity: algorithm.digestLength)
            CC_SHA256_Init(sha256Ctx)
        case .sha384:
            sha512Ctx = UnsafeMutablePointer<CC_SHA512_CTX>.allocate(capacity: algorithm.digestLength)
            CC_SHA384_Init(sha512Ctx)
        case .sha512:
            sha512Ctx = UnsafeMutablePointer<CC_SHA512_CTX>.allocate(capacity: algorithm.digestLength)
            CC_SHA512_Init(sha512Ctx)
        }
    }

    deinit {
        md5Ctx?.deallocate(capacity: algorithm.digestLength)
        sha1Ctx?.deallocate(capacity: algorithm.digestLength)
        sha256Ctx?.deallocate(capacity: algorithm.digestLength)
        sha512Ctx?.deallocate(capacity: algorithm.digestLength)
        digest?.deallocate(capacity: algorithm.digestLength)
    }

    func update(data: UnsafeMutableRawPointer, length: CC_LONG) {
        guard digest == nil else { return }

        switch algorithm {
        case .md5:
            CC_MD5_Update(md5Ctx, data, length)
        case .sha1:
            CC_SHA1_Update(sha1Ctx, data, length)
        case .sha224:
            CC_SHA224_Update(sha256Ctx, data, length)
        case .sha256:
            CC_SHA256_Update(sha256Ctx, data, length)
        case .sha384:
            CC_SHA384_Update(sha512Ctx, data, length)
        case .sha512:
            CC_SHA512_Update(sha512Ctx, data, length)
        }
    }

    func final() {
        guard digest == nil else { return }

        digest = UnsafeMutablePointer<UInt8>.allocate(capacity: algorithm.digestLength)

        switch algorithm {
        case .md5:
            CC_MD5_Final(digest, md5Ctx)
        case .sha1:
            CC_SHA1_Final(digest, sha1Ctx)
        case .sha224:
            CC_SHA224_Final(digest, sha256Ctx)
        case .sha256:
            CC_SHA256_Final(digest, sha256Ctx)
        case .sha384:
            CC_SHA384_Final(digest, sha512Ctx)
        case .sha512:
            CC_SHA512_Final(digest, sha512Ctx)
        }
    }

    func hexString() -> String? {
        guard let digest = digest else { return nil }

        var string = ""

        for i in 0..<algorithm.digestLength {
            string += String(format: "%02x", digest[i])
        }
        
        return string
    }
}
