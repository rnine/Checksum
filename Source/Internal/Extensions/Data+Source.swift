//
//  Data+Source.swift
//  Checksum
//
//  Created by Ruben Nine on 14/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

extension Data: Sourceable {
    
    var source: Source? {
        DataSource(provider: self)
    }
}
