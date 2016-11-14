//
//  Checksum.swift
//  Checksum
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto

public typealias CompletionHandler = (_ checksum: String?) -> Void
public typealias ProgressHandler = (_ bytesProcessed: Int, _ bytesLeft: Int) -> Void

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

private let defaultChunkSize: Int = 4096


// MARK: - Public Extensions

public extension URL {

    /**
        Returns a checksum of the file's content referenced by this URL using the specified digest algorithm.

        - Parameter algorithm: The digest algorithm to use.
        - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
     
        - Note: For large local files or remote resources, you may want to try `checksum(algorithm:chunkSize:queue:progressHandler:completionHandler:)` instead.
        - SeeAlso: `checksum(algorithm:chunkSize:queue:progressHandler:completionHandler:)`

        - Returns: *(optional)* A String with the computed checksum.
     */
    func checksum(algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {

        let data = try Data(contentsOf: self, options: .mappedIfSafe)
        return try data.checksum(algorithm: algorithm, chunkSize: chunkSize)
    }

    /**
        Asynchronously returns a checksum of the file's content referenced by this URL using the specified digest algorithm.

        - Parameter algorithm: The digest algorithm to use.
        - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
        - Parameter queue: *(optional)* The dispatch queue used for processing.
        - Parameter progress: *(optional)* The closure to call to signal progress.
        - Parameter completion: The closure to call upon completion containing the checksum.
     */
    func checksum(algorithm: DigestAlgorithm,
                  chunkSize: Int = defaultChunkSize,
                  queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background),
                  progress: ProgressHandler?,
                  completion: @escaping CompletionHandler) throws {

        let data = try Data(contentsOf: self, options: .mappedIfSafe)

        data.checksum(algorithm: algorithm,
                      chunkSize: chunkSize,
                      queue: queue,
                      progress: progress,
                      completion: completion)
    }
}


public extension String {

    /**
        Returns a checksum of the String's content using the specified digest algorithm.
     
        - Parameter algorithm: The digest algorithm to use.

        - Returns: *(optional)* A String with the computed checksum.
     */
    func checksum(algorithm: DigestAlgorithm) throws -> String? {

        if let data = data(using: .utf8) {
            return try data.checksum(algorithm: algorithm)
        } else {
            return nil
        }
    }
}


public extension Data {

    /**
        Returns a checksum of the Data's content using the specified digest algorithm.

        - Parameter algorithm: The digest algorithm to use.
        - Parameter *(optional)* chunkSize: The internal buffer's size (mostly relevant for large file computing)

        - Returns: *(optional)* A String with the computed checksum.
     */
    func checksum(algorithm: DigestAlgorithm, chunkSize: Int = defaultChunkSize) throws -> String? {

        let cc = CCWrapper(algorithm: algorithm)
        var bytesLeft = count

        withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            var uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)

            while bytesLeft > 0 {
                let bytesToCopy = Swift.min(bytesLeft, chunkSize)

                cc.update(data: uMutablePtr, length: CC_LONG(bytesToCopy))

                bytesLeft -= bytesToCopy
                uMutablePtr += bytesToCopy
            }
        }
        
        cc.final()
        return cc.hexString()
    }

    /**
        Asynchronously returns a checksum of the Data's content using the specified digest algorithm.

        - Parameter algorithm: The digest algorithm to use.
        - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
        - Parameter queue: *(optional)* The dispatch queue used for processing.
        - Parameter progress: *(optional)* The closure to call to signal progress.
        - Parameter completion: The closure to call upon completion containing the checksum.
     */
    func checksum(algorithm: DigestAlgorithm,
                  chunkSize: Int = defaultChunkSize,
                  queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background),
                  progress: ProgressHandler?,
                  completion: @escaping CompletionHandler) {

        queue.async {
            let cc = CCWrapper(algorithm: algorithm)
            var bytesLeft = self.count

            self.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
                var uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)

                while bytesLeft > 0 {
                    let bytesToCopy = Swift.min(bytesLeft, chunkSize)

                    cc.update(data: uMutablePtr, length: CC_LONG(bytesToCopy))

                    bytesLeft -= bytesToCopy
                    uMutablePtr += bytesToCopy

                    let actualBytesLeft = bytesLeft

                    DispatchQueue.main.async {
                        progress?(bytesToCopy, actualBytesLeft)
                    }
                }
            }

            cc.final()

            DispatchQueue.main.async {
                completion(cc.hexString())
            }
        }
    }
}


// MARK: - CCWrapper (for internal use)

private class CCWrapper {

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

        digest?.deallocate(capacity: algorithm.digestLength)
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
