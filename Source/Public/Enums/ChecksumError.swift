//
//  ChecksumError.swift
//  Checksum
//
//  Created by Ruben Nine on 14/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

/// An error returned by a checksum completion handler response.
public enum ChecksumError: Error {
    /// The source is unusable (typically due to an unsupported URL scheme, unreachable URL, etc.)
    case unusableSource

    /// Unknown error.
    case unknown
}
