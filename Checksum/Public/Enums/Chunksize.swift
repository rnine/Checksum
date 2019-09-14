//
//  Chunksize.swift
//  Checksum
//
//  Created by Ruben Nine on 21/07/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

public enum Chunksize {
    case tiny // 16kb
    case small // 64kb
    case normal // 256kb
    case large // 1mb
    case huge // 4mb
    case custom(size: Int)

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
