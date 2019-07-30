//
//  URLContentStreamer.swift
//  Checksum
//
//  Created by Ruben Nine on 12/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import CommonCrypto.CommonDigest
import Foundation

internal final class URLContentStreamer {
    private let source: Source
    private let availableSources: [Source.Type] = [FileSource.self, HTTPSource.self]

    init?(url: URL) {
        guard let urlScheme = url.scheme else { return nil }
        guard let sourceType = (availableSources.first { $0.schemes.contains(urlScheme) }) else { return nil }

        if let source = sourceType.init(url: url) {
            self.source = source
        } else {
            return nil
        }
    }

    func checksum(algorithm: DigestAlgorithm,
                  chunkSize: Chunksize = .normal,
                  queue: DispatchQueue = .global(qos: .background),
                  progress: ProgressHandler?,
                  completion: @escaping CompletionHandler) {
        queue.async {
            let cc = CCWrapper(algorithm: algorithm)
            var processedBytes: Int = 0

            while !self.source.eof() {
                guard let data = self.source.read(amount: chunkSize.bytes) else { break }

                data.withUnsafeBytes { (ptr) -> Void in
                    guard let uMutablePtr = UnsafeMutableRawPointer(mutating: ptr.baseAddress) else { return }

                    cc.update(data: uMutablePtr, length: CC_LONG(data.count))
                    processedBytes += data.count

                    DispatchQueue.main.async {
                        progress?(processedBytes, self.source.size)
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
