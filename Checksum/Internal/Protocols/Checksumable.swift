//
//  Checksumable.swift
//  Checksum
//
//  Created by Ruben Nine on 30/07/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

protocol Checksumable {
    var hashValue: Int { get }

    func checksum(algorithm: DigestAlgorithm, chunkSize: Chunksize, queue: DispatchQueue,
                  progress: ProgressHandler?, completion: @escaping CompletionHandler)
}
