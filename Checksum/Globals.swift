//
//  Globals.swift
//  Checksum
//
//  Created by Ruben Nine on 30/07/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (_ checksum: String?) -> Void
public typealias MultipleCompletionHandler = (_ checksums: [String?]) -> Void
public typealias ProgressHandler = (_ bytesProcessed: Int, _ totalBytes: Int) -> Void

public struct Defaults {
    /// Default dispatch queue to use by checksum calculations (global background.)
    public static let dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .background)
}
