//
//  URLContentStreamer.swift
//  Checksum
//
//  Created by Ruben Nine on 12/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation
import CommonCrypto.CommonDigest

final internal class URLContentStreamer {

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
                  chunkSize: Int = Defaults.chunkSize,
                  queue: DispatchQueue = .global(qos: .background),
                  progress: ProgressHandler?,
                  completion: @escaping CompletionHandler) {
        queue.async {
            let cc = CCWrapper(algorithm: algorithm)

            while !self.source.eof() {
                guard let data = self.source.read(amount: chunkSize) else { break }

                data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
                    var uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)
                    cc.update(data: uMutablePtr, length: CC_LONG(data.count))
                    uMutablePtr += data.count

                    DispatchQueue.main.async {
                        let totalBytes = self.source.size
                        progress?(data.count, totalBytes)
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
