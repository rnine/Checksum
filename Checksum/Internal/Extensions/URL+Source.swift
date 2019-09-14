//
//  URL+Source.swift
//  Checksum
//
//  Created by Ruben Nine on 14/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

extension URL: Sourceable {

    var source: Source? {
        switch scheme {
        case "http":
            fallthrough
        case "https":
            return HTTPSource(provider: self)
        case "file":
            return FileSource(provider: self)
        default:
            return nil
        }
    }
}
