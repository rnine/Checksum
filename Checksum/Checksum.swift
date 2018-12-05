//
//  Checksum.swift
//  Checksum
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto.CommonDigest

public typealias CompletionHandler = (_ checksum: String?) -> Void
public typealias MultipleCompletionHandler = (_ checksums: [String?]) -> Void
public typealias ProgressHandler = (_ bytesProcessed: Int, _ totalBytes: Int) -> Void

public struct Defaults {
    /// Default chunk size (256Kb.)
    public static let chunkSize: Int = 262144
    /// Default dispatch queue to use by checksum calculations (global background.)
    public static let dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .background)
}

internal protocol Checksumable {

    var hashValue: Int { get }

    func checksum(algorithm: DigestAlgorithm, chunkSize: Int, queue: DispatchQueue, progress: ProgressHandler?, completion: @escaping CompletionHandler)
}

//
// MARK: - URL Extension
//
extension URL {

    ///
    /// Asynchronously returns a checksum of the file's content referenced by this URL using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
    /// - Parameter queue: *(optional)* The dispatch queue used for processing.
    /// - Parameter progress: *(optional)* The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the checksum.
    ///
    public func checksum(algorithm: DigestAlgorithm,
                chunkSize: Int = Defaults.chunkSize,
                queue: DispatchQueue = Defaults.dispatchQueue,
                progress: ProgressHandler?,
                completion: @escaping CompletionHandler) {
        guard let stream = URLContentStreamer(url: self) else {
            completion(nil)
            return
        }

        stream.checksum(algorithm: algorithm,
                        chunkSize: chunkSize,
                        queue: queue,
                        progress: progress,
                        completion: completion)
    }
}

//
// MARK: - String Extension
//
extension String {

    ///
    /// Returns a checksum of the String's content using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Returns: *(optional)* A String with the computed checksum.
    ///
    public func checksum(algorithm: DigestAlgorithm) -> String? {
        if let data = data(using: .utf8) {
            return data.checksum(algorithm: algorithm)
        } else {
            return nil
        }
    }
}


extension Data {

    ///
    /// Returns a checksum of the data's content using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: *(optional)* The internal buffer's size (mostly relevant for large file computing.)
    ///
    /// - Returns: *(optional)* A string with the computed checksum.
    ///
    public func checksum(algorithm: DigestAlgorithm, chunkSize: Int = Defaults.chunkSize) -> String? {
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

    ///
    /// Asynchronously returns a checksum of the data's content using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
    /// - Parameter queue: *(optional)* The dispatch queue used for processing.
    /// - Parameter progress: *(optional)* The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the checksum.
    ///
    public func checksum(algorithm: DigestAlgorithm,
                         chunkSize: Int = Defaults.chunkSize,
                         queue: DispatchQueue = Defaults.dispatchQueue,
                         progress: ProgressHandler?,
                         completion: @escaping CompletionHandler) {
        queue.async {
            let cc = CCWrapper(algorithm: algorithm)
            let totalBytes = self.count
            var bytesLeft = totalBytes

            self.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
                var uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)

                while bytesLeft > 0 {
                    let bytesToCopy = Swift.min(bytesLeft, chunkSize)

                    cc.update(data: uMutablePtr, length: CC_LONG(bytesToCopy))

                    bytesLeft -= bytesToCopy
                    uMutablePtr += bytesToCopy

                    let actualBytesLeft = bytesLeft

                    DispatchQueue.main.async {
                        progress?(totalBytes - actualBytesLeft, totalBytes)
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

private func collectionChecksum(for collection: [Checksumable],
                                algorithm: DigestAlgorithm,
                                chunkSize: Int = Defaults.chunkSize,
                                queue: DispatchQueue = Defaults.dispatchQueue,
                                progress: ProgressHandler?,
                                completion: @escaping MultipleCompletionHandler) {

    var checksumDict = [Int: String?]()
    var progressHandlers = [Int: ProgressHandler]()
    var stats = [Int: (bytesProcessed: Int, totalBytes: Int)]()
    let total = collection.count
    let globalProgress = progress

    for item in collection {
        progressHandlers[item.hashValue] = { bytesProcessed, totalBytes in
            if stats[item.hashValue] == nil {
                stats[item.hashValue] = (Swift.max(0, bytesProcessed), Swift.max(0, totalBytes))
            } else {
                stats[item.hashValue]?.bytesProcessed = Swift.max(0, bytesProcessed)
                stats[item.hashValue]?.totalBytes = Swift.max(0, totalBytes)
            }

            let sum = stats.values.reduce(into: (0, 0)) {
                $0.0 += $1.bytesProcessed
                $0.1 += $1.totalBytes
            }

            globalProgress?(sum.0, sum.1)
        }

        item.checksum(algorithm: algorithm, chunkSize: chunkSize, queue: queue, progress: progressHandlers[item.hashValue]) { checksum in
            checksumDict[item.hashValue] = checksum

            if checksumDict.count == total {
                DispatchQueue.main.async {
                    let checksums = collection.compactMap { checksumDict[$0.hashValue] }
                    completion(checksums)
                }
            }
        }
    }
}

public extension Array where Element == URL {

    ///
    /// Asynchronously returns an array of checksums for the contents of every `URL` in this array using the specified digest algorithm.
    ///
    /// The returned checksums array is returned in the same order as this array.
    ///
    /// Finally, checksums that failed to calculate will be returned as `nil`.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
    /// - Parameter queue: *(optional)* The dispatch queue used for processing.
    /// - Parameter progress: *(optional)* The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the checksums array.
    ///
    public func checksum(algorithm: DigestAlgorithm,
                         chunkSize: Int = Defaults.chunkSize,
                         queue: DispatchQueue = Defaults.dispatchQueue,
                         progress: ProgressHandler?,
                         completion: @escaping MultipleCompletionHandler) {

        return collectionChecksum(for: self, algorithm: algorithm, chunkSize: chunkSize, progress: progress, completion: completion)
    }
}

public extension Array where Element == Data {

    ///
    /// Asynchronously returns an array of checksums for all the `Data` objects in this array using the specified digest algorithm.
    ///
    /// The returned checksums array is returned in the same order as this array.
    ///
    /// Finally, checksums that failed to calculate will be returned as `nil`.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: *(optional)* The processing buffer's size (mostly relevant for large file computing)
    /// - Parameter queue: *(optional)* The dispatch queue used for processing.
    /// - Parameter progress: *(optional)* The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the checksums array.
    ///
    public func checksum(algorithm: DigestAlgorithm,
                         chunkSize: Int = Defaults.chunkSize,
                         queue: DispatchQueue = Defaults.dispatchQueue,
                         progress: ProgressHandler?,
                         completion: @escaping MultipleCompletionHandler) {

        return collectionChecksum(for: self, algorithm: algorithm, chunkSize: chunkSize, progress: progress, completion: completion)
    }
}

// Adding Checksumable protocol conformance to URL
extension URL: Checksumable {}

// Adding Checksumable protocol conformance to Data
extension Data: Checksumable {}
