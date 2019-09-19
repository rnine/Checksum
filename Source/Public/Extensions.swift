//
//  Extensions.swift
//  Checksum
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import CommonCrypto.CommonDigest
import Foundation

/// Closure type executed after a checksum calculation process finished.
public typealias CompletionHandler = (Result<String, ChecksumError>) -> Void

/// Closure type executed after a multiple checksum calculation process finished.
public typealias MultipleCompletionHandler = (Result<[ChecksumResult], ChecksumError>) -> Void

/// Closure type executed when monitoring the checksum process.
public typealias ProgressHandler = (Progress) -> Void

/// A tuple containing a `Checksumable` and its optional `String` checksum.
public typealias ChecksumResult = (checksumable: Checksumable, checksum: String?)

// MARK: - String Extension

// Adding Checksumable protocol conformance to String
extension String: Checksumable {}

// MARK: - Data Extension

// Adding Checksumable protocol conformance to Data
extension Data: Checksumable {}

// MARK: - URL Extension

// Adding Checksumable protocol conformance to URL
extension URL: Checksumable {}

// MARK: - Checksumable Extension

extension Checksumable {
    /// On completion, returns a checksum of this `Checksumable` using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: The processing buffer's size (mostly relevant for large data computing)
    /// - Parameter queue: The dispatch queue on which to call progress and completion closures.
    /// - Parameter progress: The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the result.
    public func checksum(algorithm: DigestAlgorithm,
                         chunkSize: Chunksize = .normal,
                         queue: DispatchQueue = .main,
                         progress: ProgressHandler? = nil,
                         completion: @escaping CompletionHandler) {
        guard let source = (self as? Sourceable)?.source else {
            queue.async {
                completion(.failure(.unusableSource))
            }

            return
        }

        DispatchQueue.global(qos: .background).async {
            let cc = CCWrapper(algorithm: algorithm)
            let overallProgress = Progress()

            while !source.eof() {
                guard let data = source.read(amount: chunkSize.bytes) else { break }

                overallProgress.totalUnitCount = Int64(source.size)

                data.withUnsafeBytes { (ptr) -> Void in
                    guard let uMutablePtr = UnsafeMutableRawPointer(mutating: ptr.baseAddress) else { return }

                    cc.update(data: uMutablePtr, length: CC_LONG(data.count))
                    overallProgress.completedUnitCount += Int64(data.count)

                    if let progress = progress {
                        queue.async {
                            progress(overallProgress)
                        }
                    }
                }
            }

            cc.final()

            queue.async {
                if let checksum = cc.hexString() {
                    completion(.success(checksum))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }

    /// Returns a checksum of this `Checksumable` using the specified digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: The internal buffer's size (mostly relevant for large data computing.)
    ///
    /// - Returns: A `String` containing with the computed checksum.
    public func checksum(algorithm: DigestAlgorithm, chunkSize: Chunksize = .normal) -> String? {
        var checksum: String?
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)

        dispatchGroup.enter()

        self.checksum(algorithm: algorithm, chunkSize: chunkSize, queue: dispatchQueue) { result in
            checksum = try? result.get()
            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        return checksum
    }
}

// MARK: - Checksumable Array Extension

public extension Array where Element: Checksumable {
    /// On completion, returns a `ChecksumResult` for every `Checksumable` in this array using the specified
    /// digest algorithm.
    ///
    /// - Parameter algorithm: The digest algorithm to use.
    /// - Parameter chunkSize: The processing buffer's size (mostly relevant for large data computing)
    /// - Parameter queue: The dispatch queue used for processing.
    /// - Parameter progress: The closure to call to signal progress.
    /// - Parameter completion: The closure to call upon completion containing the result.
    func checksum(algorithm: DigestAlgorithm,
                  chunkSize: Chunksize = .normal,
                  queue: DispatchQueue = .main,
                  progress: ProgressHandler? = nil,
                  completion: @escaping MultipleCompletionHandler) {
        var checksums = [ChecksumResult]()
        let overallProgress = Progress(totalUnitCount: Int64(count))

        for element in self {
            let elementProgress = Progress()
            overallProgress.addChild(elementProgress, withPendingUnitCount: 1)

            let progressHandler: ProgressHandler = {
                elementProgress.totalUnitCount = $0.totalUnitCount
                elementProgress.completedUnitCount = $0.completedUnitCount

                progress?(overallProgress)
            }

            element.checksum(algorithm: algorithm, chunkSize: chunkSize, queue: queue, progress: progressHandler) { result in
                checksums.append((checksumable: element, checksum: try? result.get()))

                if checksums.count == self.count {
                    queue.async {
                        completion(.success(checksums))
                    }
                }
            }
        }
    }
}
