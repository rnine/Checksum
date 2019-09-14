//
//  String+Source.swift
//  Checksum
//
//  Created by Ruben Nine on 14/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

extension String: Sourceable {

    var source: Source? {
        guard let data = data(using: .utf8) else { return nil }
        return DataSource(provider: data)
    }
}
