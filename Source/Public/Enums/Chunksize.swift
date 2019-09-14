//
//  Chunksize.swift
//  Checksum
//
//  Created by Ruben Nine on 21/07/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

/// Represents a size to be used for chunk processing.
public enum Chunksize {
    /// Tiny (16kb)
    case tiny

    /// Small (64kb)
    case small

    /// Normal (256kb)
    case normal

    /// Large (1mb)
    case large

    /// Huge (4mb)
    case huge

    /// Custom (user-settable)
    case custom(size: Int)
}

internal extension Chunksize {
    var bytes: Int {
        switch self {
        case .tiny:
            return 16384
        case .small:
            return 65536
        case .normal:
            return 262_144
        case .large:
            return 1_048_576
        case .huge:
            return 4_194_304
        case let .custom(size):
            return size
        }
    }
}
