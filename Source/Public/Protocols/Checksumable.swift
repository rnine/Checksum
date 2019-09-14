//
//  Checksumable.swift
//  Checksum
//
//  Created by Ruben Nine on 30/07/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

/// The protocol any subject whose checksum may be calculated must conform to.
public protocol Checksumable {
    /// :nodoc:
    var hashValue: Int { get }

    /// :nodoc:
    func checksum(algorithm: DigestAlgorithm, chunkSize: Chunksize, queue: DispatchQueue,
                  progress: ProgressHandler?, completion: @escaping CompletionHandler)
}
